This app is an api boilerplate, integrated with MyECP-oauth2 for authentication, 
and focused on security concerns.

# Configuration

Two workflows are available for the boilerplate :
   - **docker-compose** workflow
   - **native** workflow
   
Whichever is your configuration, you must do `npm install`.
    

## Docker workflow

Copy `docker/docker-compose.yml.template` to `docker/docker-compose.yml` and edit it.

According to all `YOUR_APP_*` environment variables in `docker/docker-compose.yml` add :
- NODE_ENV : production || development
- JWT secret for your environment.
- Redis  secret for your environment

### Secure

#### Certificates

For the moment secure docker workflow only supports self-signed certificates.

First, copy `docker/config/openssl-ca.cnf.template` to `docker/config/openssl-ca.cnf`, and complete the configuration file.
This will be the Certificate Authority file.

Then, copy `docker/config/openssl-client.cnf.template` to `docker/config/openssl-ca.cnf`, and complete the configuration file.
This will be used to generate the certificate signing request.

Edit appropriate `config/env/`:
- Add `secure_mongo: true`, `built_in_docker: true`, and `db` should start with `mongodb://mongo/`. Ignore `clientCert`, `clientKey` and `ca`. 
- Port should match exposed port in `docker/docker-compose.yml`

### Insecure

Does not work yet

## Native workflow
    
Install `mongodb`. To do : check other steps.
