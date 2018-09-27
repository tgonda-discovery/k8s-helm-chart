import time
from DivvyPlugins.hookpoints import hookpoint
from DivvyPlugins.plugin_metadata import PluginMetadata
import logging
from flask import request
import time
from DivvyApp.DivvyApp import DivvyApp
import os


class metadata(PluginMetadata):
    """
    Information about this plugin
    """
    version = '1.0'
    last_updated_date = '2016-03-18'
    author = 'Divvy Cloud Corp.'
    nickname = 'Stats Plugin'
    default_language_description = 'Send Job Stats'
    support_email = 'support@divvycloud.com'
    support_url = 'http://support.divvycloud.com'
    main_url = 'http://www.divvycloud.com'
    category = 'Utils'
    managed = True
    divvy_api_version = "16.01"


def memory_usage_psutil():
    # return the memory usage in MB
    import psutil
    process = psutil.Process(os.getpid())
    mem = process.memory_info()[0] / float(2 ** 20)
    return mem


@hookpoint("divvycloud.app.heartbeat")
def record_memory(last_heartbeat_time):
    from influxdb import InfluxDBClient
    client = InfluxDBClient('data-influxdb.tick', 8086,
                            '', '', 'process_stats')
    json_body = [
        {
            "measurement": "memory_usage",
            "tags": {
                "process_name": DivvyApp().serviceName
            },
            "fields": {
                "memory_usage": memory_usage_psutil()
            }
        }
    ]
    client.write_points(json_body)


@hookpoint('divvycloud.job.begin')
def begin_job_stats(job_object):
    job_object.job_start_time = time.time()


@hookpoint('divvycloud.job.complete')
def end_job_stats(job_object, result):
    if not hasattr(job_object, "job_start_time"):
        return

    job_elapsed_time = time.time() - job_object.job_start_time
    region_name = None
    try:
        job_name = "harvester.%s.%s.time" % (
            job_object.__class__.__name__, job_object.current_location.region_name)
        region_name = job_object.current_location.region_name
    except:
        job_name = "harvester.%s.time" % (job_object.__class__.__name__)

    json_body = [
        {
            "measurement": "harvest_time",
            "tags": {
                "harvest_time": job_object.__class__.__name__,
                "region": region_name
            },
            "fields": {
                "elapsed_time_ms": job_elapsed_time
            }
        }
    ]
    send_payload(json_body)
    return


def send_payload(json_body):
    global client
    client.write_points(json_body)


def start_request_timer():
    request.start_time = time.time()


def end_request_time(response):
    global client
    resp_time = time.time() - request.start_time
    json_body = [
        {
            "measurement": "api_call",
            "tags": {
                "path": request.path,
                "method": request.method,
                "status_code": response.status_code
            },
            "fields": {
                "elapsed_time_ms": resp_time
            }
        }
    ]
    send_payload(json_body)
    return response


def patch_flask():
    from DivvyInterfaceServer.DivvyInterfaceServer import get_all_flask_apps
    current_app = get_all_flask_apps()['']
    current_app.before_request(start_request_timer)
    current_app.after_request(end_request_time)


def install_packages():
    import pip
    logging.info("Installing Statsd-tags")
    pip.main(['install', 'influxdb'])
    pip.main(['install', 'psutil'])


def setup_influx_client():
    from influxdb import InfluxDBClient
    logging.info("Loading Influxdb plugin")
    global client
    if DivvyApp().serviceName == 'DivvyInterfaceServer':
        client = InfluxDBClient('data-influxdb.tick', 8086, '', '', 'api')
    else:
        client = InfluxDBClient('data-influxdb.tick',
                                8086, '', '', 'divvycloud')


def load():
    install_packages()
    setup_influx_client()
    if DivvyApp().serviceName == 'DivvyInterfaceServer':
        # Add our API measurement middleware
        patch_flask()
    return


def unload():
    global client
    del client
