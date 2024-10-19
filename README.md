# bsky-pds

## Introduction

bsky-pds was created to easily run a Bluesky PDS on Docker with external access established using a Cloudflare tunnel.

## Disclaimer

Use this project at your own risk. Self hosting a PDS is a journey not for the faint of heart. You should know your way around Bluesky, atproto, PLC, Docker, and Cloudflare. You should always backup your data and be prepared for data loss at any moment.

## Configuring

Clone the repository to your Docker host. Copy `pds.env.example` to `pds.env` and fill out all required fields. Copy `tunnel.env.example` to `tunnel.env` and configure with your Cloudflare tunnel details. Your Cloudflare tunnel should point to `http://pds:3000`.

### Cloudflare Limitations

Cloudflare doesnt support SSL on domain sub sub domains on the free plan, it's only supported with a custom certificate or by using Advanced Certificate Manager.

When self hosting a PDS you will get invalid.handle errors unless secure access is possible to https://yourusername.pds.example.com for example, where pds.example.com is your PDS hostname. You can work around this by setting a TXT record for yourusername.pds.example.com to authenticate your DID to your handle instead.

## Running

bsky-pds was designed to be run using Docker Compose, if you should proceed you'll know what to do next.

## Administration

Use the `pdsadmin.sh` script to perform administration of your new PDS. You can get started with `pdsadmin.sh help`.

## Support

Support is limited. All the risk is yours. However, if you get too stuck you'll find me on Bluesky, [@lukeacl.com](https://bsky.app/profile/lukeacl.com).

## Contributing

This is a personal project published for others to use if they want. If you're using it and spot a problem or can make an improvement submit a pull request. I'm all ears and happy to take a look!

## Credit

This would not be possible without the incredible work of [bluesky-social](https://github.com/bluesky-social).