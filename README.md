# ABAP_ChatGPT_Client

## Description:

This was a fun mini project I did during my holidays.
I hope it helps you integrate openai prompts into your system.

## Contents:

- Abap Class Z_OPENAI_COMPLETION wich lets you choose a few relevant parameters like the ai model and execute prompts.
- Abap Report Z_TEST_OPENAI_COMPLETION wich can be used to execute a prompt or test your connections

## My System:

I'm using the SAP NetWeaver AS ABAP Developer Edition 7.52 SP04 wich can be downloaded here:
- https://developers.sap.com/trials-downloads.html?search=abap

Also I'm using Oracle VM Virtual Box and Opensuse 15.3 Version.

There are resources available on how to install everything on a VM.

## Obstacles I encountered:

Since it took quite a bit time to get the connections running,
I want to share the things I had to do first:

- Add my wireless network card to my machine as eth1

- Add a routing table entry with the adress of my router, wich could be done via the command:
  - ip route add <router address> dev eth1
  
  Since I'm using Gnome as desktop environment I just opened YAST Network and added the entry there:
  - Destination 0.0.0.0
  - Gateway < Router IP address >
  - eth1

- Add the following lines to file /sapmnt/NPL/profile/DEFAULT.PFL
  - ssl/ciphersuites             = 135:PFS:HIGH::EC_X25519:EC_P256:EC_HIGH
  - ssl/client_ciphersuites      = 150:PFS:HIGH::EC_X25519:EC_P256:EC_HIGH
  - icm/HTTPS/client_sni_enabled = TRUE
  - ssl/client_sni_enabled       = TRUE

  - SETENV_26 = SECUDIR=$(DIR_INSTANCE)$(DIR_SEP)sec
  - SETENV_27 = SAPSSL_CLIENT_CIPHERSUITES=150:PFS:HIGH::EC_X25519:EC_P256:EC_HIGH
  - SETENV_28 = SAPSSL_CLIENT_SNI_ENABLED=TRUE 

- Add every possible ssl certificate you can get from www.openai.com and api.openai.com (should be 5x) via STRUST Transaction

## Key:

To sucessfully execute prompts, you need your own key, wich can be obtained here:

www.openai.com

There is a 5$ trial credit, you can use.


