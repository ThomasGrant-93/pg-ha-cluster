# Log and error access file
accesslog: str = "/var/log/barman/barman-api-access.log"
errorlog: str = "/var/log/barman/barman-api-error.log"

timeout: int = 60  # seconds

bind: str = "0.0.0.0:7480"  # By default the service binds on localhost only
# If you need to change it and listen to in all interfaces,
# you could set "bind 0.0.0.0:7480"
                                
