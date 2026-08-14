import logging
import pytz
from datetime import datetime
import sys
import warnings
import os
import google.cloud.logging
from google.cloud.logging.handlers import CloudLoggingHandler

class SouthAfricaFormatter(logging.Formatter):
    def formatTime(self, record, datefmt=None):
        tz = pytz.timezone('Africa/Johannesburg')
        dt = datetime.fromtimestamp(record.created, tz)
        if datefmt:
            s = dt.strftime(datefmt)
        else:
            s = dt.strftime('%Y-%m-%d %H:%M:%S')
        return s

def setup_logger(log_file_path=None):
    script_name = os.path.basename(sys.argv[0])

    # Initialize the logger with the script name
    logger = logging.getLogger(script_name)
    logger.setLevel(logging.DEBUG)

    # StreamHandler for console logging
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)

    formatter = SouthAfricaFormatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    try:
        client = google.cloud.logging.Client()
        cloud_handler = CloudLoggingHandler(client)
        cloud_handler.setFormatter(formatter)
        logger.addHandler(cloud_handler)
        logger.info("Google Cloud Logging successfully initialized.")
    except Exception as e:
        logger.error("Failed to initialize Google Cloud Logging: %s", str(e))

    # Optional FileHandler for file logging
    if log_file_path:
        file_handler = logging.FileHandler(log_file_path)
        file_handler.setLevel(logging.INFO)  # Set to INFO to log only INFO and higher levels
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        logger.info(f"File logging initialized at {log_file_path}")

    # ---Redirect stdout and stderr to logger
    class StreamToLogger:
        def __init__(self, logger, log_level=logging.INFO):
            self.logger = logger
            self.log_level = log_level
            self.linebuf = ''

        def write(self, buf):
            warning_phrases = [
                "Program shutting down",
                "Waiting up to 5 seconds",
                "Sent all pending logs"
            ]
            
            for line in buf.rstrip().splitlines():
                if any(phrase in line for phrase in warning_phrases):
                    self.logger.warning(line.rstrip())
                else:
                    self.logger.log(self.log_level, line.rstrip())

        def flush(self):
            pass

    sys.stdout = StreamToLogger(logger, logging.INFO)
    sys.stderr = StreamToLogger(logger, logging.ERROR)

    # Capture warnings into logs
    def warning_to_log(message, category, filename, lineno, file=None, line=None):
        logger.warning(f'{filename}:{lineno}: {category.__name__}: {message}')
    warnings.showwarning = warning_to_log
    warnings.simplefilter("always")

    return logger
