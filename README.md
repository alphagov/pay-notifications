# pay-notifications

Alpine image with Nginx/Naxsi for receiving notifications from payment service providers.

The naxsi configuration is kept in [pay-infra](https://github.com/alphagov/pay-infra/blob/master/provisioning/terraform/modules/pay_notifications/files/notifications.naxsi) 
and pushed to S3 by [a Terraform module](https://github.com/alphagov/pay-infra/blob/master/provisioning/terraform/modules/pay_notifications/naxsi.tf)
which runs as part of the Notifications deployment pipeline.

For local development and test purposes, docker copies a stub naxsi config 
(`tests/rules-stub.naxsi`) into the notifications image.

When the notifications container starts in AWS, the `docker-start.sh` script
pulls the naxsi config from S3, overwriting the stub file, before
starting nginx.

For local development, you can manually mount the naxsi config from a checkout
of pay-infra by adding `-v 
$PAY_INFRA/provisioning/terraform/modules/pay_notifications/files/notifications.naxsi:/etc/nginx/naxsi.rules`
to your `docker run` command.  (Where $PAY_INFRA points to a local checkout of 
that repo.)

## Licence
[MIT License](LICENCE)

## Vulnerability Disclosure

GOV.UK Pay aims to stay secure for everyone. If you are a security researcher and have discovered a security vulnerability in this code, we appreciate your help in disclosing it to us in a responsible manner. Please refer to our [vulnerability disclosure policy](https://www.gov.uk/help/report-vulnerability) and our [security.txt](https://vdp.cabinetoffice.gov.uk/.well-known/security.txt) file for details.
