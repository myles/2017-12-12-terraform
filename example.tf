// resource "type" "name" { options }

resource "heroku_app" "app" {}

resource "digitalocean_droplet" "worker" {
  image = "ubuntu-14-04-x64"
  name = "worker"
  region = "nyc2"
  size = "512mb"

  provisioner "ansible" {
    connection {
      user = "deploy"
    }

    playbook = "ansible/playbook.yml"
    groups = ["all"]
    hosts = ["worker"]
  }
}

resource "aws_s3_bucket" "photos" {
  bucket = "photos.myles.photo"
}

resource "aws_route53_zone" "myles_photo" {
  name = "myles.photo."
}

resource "aws_route53_record" "app_myles_photo" {
  zone_id = "${data.aws_route53_zone.myles_photo.id}"
  name = "app.${data.aws_route53_zone.myles_photo.name}"
  type = "CNAME"
  records = ["${data.heroku_app.app.heroku_hostname}"]
}


resource "aws_route53_record" "photos_myles_photo" {
  zone_id = "${data.aws_route53_zone.myles_photo.id}"
  name = "photos.${data.aws_route53_zone.myles_photo.name}"
  type = "A"

  alias {
    name = "${data.aws_s3_bucket.photos.website_domain}"
    zone_id = "${data.aws_s3_bucket.photos.hosted_zone_id}"
  }
}
