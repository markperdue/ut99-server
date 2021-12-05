A no nonsense Unreal Tournament 99 server running the latest v469b patch on debian 11. The server is the Game of the Year edition so it includes bonus packs 1 through 3.

This image adds support for injecting custom maps, sounds, textures, and system files into the appropriate directories. See the compose file for an example but in general:
- environment variable `APPLY_CUSTOM_FILES` must be set to true
- any .unr files file mounted to /tmp/Maps will be copied to /opt/ut-server/Maps/
- any .umx files file mounted to /tmp/Music will be copied to /opt/ut-server/Music/
- any .utx or  files file mounted to /tmp/Textures will be copied to /opt/ut-server/Textures/
- any .u and .ini  files file mounted to /tmp/System will be copied to /opt/ut-server/System/

It is highly recommended that a customized `UnrealTournament.ini` is created and made available as a file mount to `/opt/ut-server/System/UnrealTournament.ini`

This container runs as a non-root user unlike many other versions.

## Quick Start
Start a ut99 server:
```
docker run --name ut99-server -p 5080:5080 -p 7777-7781:7777-7781/udp -p 27900:27900/udp mperdue/ut99-server:latest
```

A ut99 server called 'Another UT Server' will be launched. To customize this server, see below.

## Configuration
A fully customized ut99 server can be created through a combination of environment variables and a customized `UnrealTournament.ini` file that is mounted into the container. The suggested way to do this is through a `docker-compose` file.

### Environment Variables
| Variable             | Description                                              | Allowed values  | Default                                                     |
| -------------------- | -------------------------------------------------------- | --------------- | ----------------------------------------------------------- |
| `APPLY_CUSTOM_FILES` | inject custom files into the ut-server directories       | `true`, `false` | unset                                                       |
| `SERVER_STRING`      | ut99 server string that will be passed to ucc-bin server |  string         | `CTF-Coret?game=BotPack.CTFGame?mutator=BotPack.InstaGibDM` |

### Example `docker-compose.yml` file
An example docker-compose.yml file is below.

This configuration will start up a lowgrav instagib CTF server and add aditional maps, sounds, textures, and system files from a host location to the server. A customized `UnrealTournament.ini` is added to replace the default file.
```yaml
version: "3"
services:
  ut99:
    image: mperdue/ut99-server:latest
    container_name: ut99-server
    ports:
      - "5080:5080/tcp"
      - "7777-7781:7777-7781/udp"
      - "27900:27900/udp"
    environment:
      - SERVER_STRING=CTF-ThornsV2?game=BotPack.CTFGame?mutator=BotPack.InstaGibDM,BotPack.LowGrav
      - APPLY_CUSTOM_FILES=true
    volumes:
      - /home/user/config/ut99-server/Maps:/tmp/Maps
      - /home/user/config/ut99-server/Sounds:/tmp/Sounds
      - /home/user/config/ut99-server/Textures:/tmp/Textures
      - /home/user/config/ut99-server/System:/tmp/System
      - /home/user/config/ut99-server/UnrealTournament.ini:/opt/ut-server/System/UnrealTournament.ini
```

### Example `docker-compose.yml` file with redirect server
A redirect server for quick map downloads can be easily spun up along side the server with the following docker-compose file. Using a redirect server is likely redundant as ut99 is started up with the `-lanplay` flag but a sample configuration to do so is shown below:
```yaml
version: "3"
services:
  ut99:
    image: mperdue/ut99-server:latest
    container_name: ut99-server
    ports:
      - "5080:5080/tcp"
      - "7777-7781:7777-7781/udp"
      - "27900:27900/udp"
    environment:
      - SERVER_STRING=CTF-ThornsV2?game=BotPack.CTFGame?mutator=BotPack.InstaGibDM,BotPack.LowGrav
      - APPLY_CUSTOM_FILES=true
    volumes:
      - /home/user/config/ut99-server/Maps:/tmp/Maps
      - /home/user/config/ut99-server/Sounds:/tmp/Sounds
      - /home/user/config/ut99-server/Textures:/tmp/Textures
      - /home/user/config/ut99-server/System:/tmp/System
      - /home/user/config/ut99-server/UnrealTournament.ini:/opt/ut-server/System/UnrealTournament.ini
  nginx:
    image: nginx:alpine
    container_name: ut99-nginx
    ports:
      - "8081:80/tcp"
    volumes:
      - /home/user/config/ut99-server/Redirect:/usr/share/nginx/html:ro
```

Note - additional configuration would be needed within `UnrealTournament.ini` to set `RedirectToURL`

### Base config changes
Changelog of UnrealTournament.ini from base version
- removes [Engine.GameEngine] ServerActors=IpServer.UdpServerUplink MasterServerAddress=master0.gamespy.com MasterServerPort=27900
- updates [Engine.Player] ConfiguredInternetSpeed=2600 to ConfiguredInternetSpeed=20000
- adds [Botpack.DeathMatchPlus] MinPlayers=10
- sets [Botpack.CTFGame] GoalTeamScore=5 and TimeLimit=20
- sets [Engine.GameInfo] bWorldLog=False
- removes [UBrowserAll] ListFactories[1]=UBrowser.UBrowserGSpyFact,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut
- updates [UWeb.WebServer] bEnabled=False to bEnabled=True
- adds [IpServer.UdpServerUplink] DoUplink=True and UpdateMinutes=1 and MasterServerAddress= and MasterServerPort=27900 and Region=0
