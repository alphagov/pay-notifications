# pay-notifications

Alpine image with Nginx/Naxsi for receiving notifications from payment service providers.

The naxsi configuration is kept in [pay-infra](https://github.com/alphagov/pay-infra/blob/master/provisioning/terraform/modules/pay_notifications/files/notifications.naxsi) 
and pushed to S3 by [a Terraform module](https://github.com/alphagov/pay-infra/blob/master/provisioning/terraform/modules/pay_notifications/naxsi.tf)
which runs as part of the Notifications deployment pipeline.

When the notifications container starts in AWS, the `docker-start.sh` script
pulls the naxsi config from S3, and installs it in the container before 
starting nginx.

For local development, you must manually mount the naxsi config from a checkout
of pay-infra by adding 
`-v ${PAY_INFRA}/provisioning/terraform/modules/pay_notifications/files/notifications.naxsi:/etc/nginx/naxsi.rules`
to your `docker run` command. Tests do this automatically, assuming pay-infra
is checkout out at the same level as this repository.

## Licence
[MIT License](LICENCE)

## Vulnerability Disclosure

GOV.UK Pay aims to stay secure for everyone. If you are a security researcher and have discovered a security vulnerability in this code, we appreciate your help in disclosing it to us in a responsible manner. Please refer to our [vulnerability disclosure policy](https://www.gov.uk/help/report-vulnerability) and our [security.txt](https://vdp.cabinetoffice.gov.uk/.well-known/security.txt) file for details.
