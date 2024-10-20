# bsky-pds

## Introduction

bsky-pds was created to run a Bluesky PDS on Docker with external access terminated using a Cloudflare tunnel.

## Disclaimer

Use this project at your own risk. Self hosting a PDS is a journey not for the faint of heart. You should know your way around Bluesky, atproto, PLC, Docker, and Cloudflare. You should always backup your data and be prepared for data loss at any moment.

### Cloudflare

When configuring the Cloudflare Tunnel ensure that you configure two Public Hostnames both pointing at `http://pds:3000`. One will be for the PDS hostname `pds.example.com` and the other will be a catch all for subdomains `*.pds.example.com`. You must configure the catch-all for subdomains or you will end up with invalid handle errors on your accounts.

#### Free Accounts

Cloudflare free does not support SSL on sub sub domains. If your PDS hostname is `example.com`, your catch-all `*.example.com` will work fine. If your PDS hostname however is `pds.example.com`, your catch-all `*.pds.example.com` will not work. You'll need to pay for Cloudflare Advanced Certificate Manager and make sure the certificate generated covers both `pds.example.com` and `*.pds.example.com`.

As a workaround to using sub sub domains with Cloudflare Free, you will need to create DNS TXT records for each account on your PDS using the PDS hostname. For example, if you have `user.pds.example.com`, you can configure a DNS TXT record at `_atproto.user.pds.example.com` with their DID in the value `did=did:plc:4ylkaamqhbm6qnc7fhs2vv3e`.

### Blob Storage

#### Local

Local storage is the simplest method to get started, but S3 is recommended.

#### S3

If you intend on using Amazon S3 or any other S3 compatible blob store you'll need to first create an S3 bucket, ensure it does not have public access by default. You'll then need to create an IAM user with the right permissions to store data in that bucket. The following is an example policy you might like to attach inline to enable this.

```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket",
				"s3:GetBucketLocation"
			],
			"Resource": [
				"arn:aws:s3:::blobs.pds.example.com"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:GetObject",
				"s3:GetObjectAcl",
				"s3:DeleteObject",
				"s3:ListMultipartUploadParts",
				"s3:AbortMultipartUpload"
			],
			"Resource": [
				"arn:aws:s3:::blobs.pds.example.com/*"
			]
		}
	]
}
```

Once you've setup the bucket, the user, and the permissions, you can fill in the details in `pds.env` to get it all working.

## Configuring

### pds/pds.env

```
# Service
PDS_HOSTNAME= #pds.example.com
PDS_BLOB_UPLOAD_LIMIT= #5 * 1024 * 1024 (5mb)

# Secrets
PDS_ADMIN_PASSWORD= #openssl rand --hex 16
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX= #openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32
PDS_JWT_SECRET= #openssl rand --hex 16

# Invites
PDS_INVITE_REQUIRED=true

# Email
PDS_EMAIL_SMTP_URL= #smtp://username@gmail.com:password@smtp.gmail.com:587
PDS_EMAIL_FROM_ADDRESS= #noreply@pds.example.com

# Email - Moderation
PDS_MODERATION_EMAIL_SMTP_URL= #smtp://username@gmail.com:password@smtp.gmail.com:587
PDS_MODERATION_EMAIL_ADDRESS= #noreply@pds.example.com

# Database Location
PDS_DATA_DIRECTORY=/pds

# Blob Store - Option 1 - Locally (To use, comment option 2)
# PDS_BLOBSTORE_DISK_LOCATION=/pds/blocks

# Blob Store - Option 2 - S3 (To use, comment option 1)
PDS_BLOBSTORE_S3_BUCKET= #blobs.pds.example.com
PDS_BLOBSTORE_S3_REGION= #ap-southeast-2
PDS_BLOBSTORE_S3_ENDPOINT= #https://s3.ap-southeast-2.amazonaws.com
PDS_BLOBSTORE_S3_FORCE_PATH_STYLE=true
PDS_BLOBSTORE_S3_ACCESS_KEY_ID= #accessKeyId
PDS_BLOBSTORE_S3_SECRET_ACCESS_KEY= #secretAccessKey

# Identity
PDS_DID_PLC_URL=https://plc.directory

# AppView
PDS_BSKY_APP_VIEW_URL=https://api.bsky.app
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app

# Report Service
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac

# Crawlers
PDS_CRAWLERS=https://bsky.network

# Logging
LOG_ENABLED=true
```

### pds/tunnel.env

```
TUNNEL_TOKEN= #cloudflared tunnel token
```

Clone the repository to your Docker host. Copy `pds.env.example` to `pds.env` and fill out all required fields. Copy `tunnel.env.example` to `tunnel.env` and configure with your Cloudflare tunnel details. Your Cloudflare tunnel should point to `http://pds:3000`.

## Running

bsky-pds was designed to be run using Docker Compose. You can get started by running `docker compose up` to check it's all working, then you can set it off to run unattented using `docker compose up -d` to send it to the background. Make sure you're familiar with Docker Compose commands to make your life a bit easier.

## Administration & Getting Started

Use the `pdsadmin.sh` script to perform administration of your new PDS. You can get started with `pdsadmin.sh help`. You should first create a test account, sign in using your client, create a post with an image and set a profile picture to make sure blob storage is working. If you're using a sub sub domain on a Cloudflare free account make sure you set up the appropriate DNS TXT record to enable handle to DID validation.

## Validation & Troubleshooting

Running your own PDS doesn't always go smoothly. There are a few things you can check while troubleshooting to determine if you've set things up correctly.

First make sure you can access the PDS at it's main hostname, for example accessing [https://pds.example.com/xrpc/_health](https://pds.example.com/xrpc/_health) should return the version of your PDS.

Next if you've paid for Cloudflare Advanced Certificate Manager make sure you can access [https://user.pds.example.com/.well-known/atproto-did](https://user.pds.example.com/.well-known/atproto-did), it should return the DID of your test account.

Alternatively if you're using DNS to validate the handle to the DID or in any other case you can use [https://bsky-debug.app/handle](https://bsky-debug.app/handle) to validate handle resolution. In any case you should get a pass, through HTTPS or DNS validation. One of them must succeed for your PDS to function correctly.

Once you've done a few test posts on your PDS you should makesure websockets are working using a tool like `wssdump` or `websocat` using a command like below. If it's all working properly you should see some data dump out, and if you keep it open and perform actions on your PDS you should see more data flow.

`websocat "wss://pds.example.com/xrpc/com.atproto.sync.subscribeRepos?cursor=0"`

## Support

Support is limited. All the risk is yours. However, if you get too stuck you'll find me on Bluesky, [@lukeacl.com](https://bsky.app/profile/lukeacl.com).

## Contributing

This is a personal project published for others to use if they want. If you're using it and spot a problem or can make an improvement submit a pull request. I'm all ears and happy to take a look!

## Credit

This would not be possible without the incredible work of [bluesky-social](https://github.com/bluesky-social).
