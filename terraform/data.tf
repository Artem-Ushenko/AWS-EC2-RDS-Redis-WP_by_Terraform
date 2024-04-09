# Get current IP address
data "http" "my_ip" {
  url = "http://whatismyip.akamai.com/"
}
