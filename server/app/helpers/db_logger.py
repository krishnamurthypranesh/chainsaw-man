import logging
import sys

from pymongo import monitoring

logging.basicConfig(stream=sys.stdout, level=logging.INFO)


class CommandLogger(monitoring.CommandListener):
    def started(self, event):
        logging.info(
            "Command {0.command_name} with request id "
            "{0.request_id} started on server "
            "with command: {0.command}"
            "{0.connection_id}".format(event)
        )

    def succeeded(self, event):
        logging.info(
            "Command {0.command_name} with request id "
            "{0.request_id} on server {0.connection_id} "
            "succeeded in {0.duration_micros} "
            "microseconds".format(event)
        )

    def failed(self, event):
        logging.info(
            "Command {0.command_name} with request id "
            "{0.request_id} on server {0.connection_id} "
            "failed in {0.duration_micros} "
            "microseconds".format(event)
        )


monitoring.register(CommandLogger())
