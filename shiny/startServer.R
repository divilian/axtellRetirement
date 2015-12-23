
# Start the app in headless mode.
require(shiny)

# CHANGE: Include your directory, port (if not default), and host.
runApp(appDir="/path/to/your/dir",port=yourPortNumber,launch.browser=FALSE,host="ip.addr.of.server")
