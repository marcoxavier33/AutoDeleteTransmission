# AutoDeleteTransmission

You are aware that when you delete a file from Sonarr/Radarr, it do not delete it in the transmission folder, which can cause disk space problems.
Sonarr and Radarr only delete the torrent when it has finished seeding. If you're like me and like to leave your torrents in permanent seed until you delete itin sonarr or radarr, this script might be able to help you.

The goal is simple, the script must be run regularly via the crontab, it will look if files have been deleted in the Sonarr / Radarr folders (when you delete it in the web interface, and checked the box)by comparing with the files you have in your transmission download folder. If it notices a difference then it will go and delete the torrent on transmission via the API.

YOU'LL NEED TO INSTALL JQ

YOU HAVE TO MODIFY THE VARS.INI FILE TO PUT YOUR PATH / KEYS

This script is largely optimizable, I share it with you in the current state since it works. I will probably make updates in the future.
It is also possible I think to adapt it for other download clients.
