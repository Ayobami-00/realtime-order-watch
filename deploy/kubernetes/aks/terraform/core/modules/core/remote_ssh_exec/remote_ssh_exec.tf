resource "null_resource" "copy_ec2_keys" {
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type        = "ssh"
    host        = var.host
    user        = var.user
    password    = ""
    private_key = var.private_key
  }


  provisioner "file" {
    source      = var.input_file_source
    destination = var.destination_file_path
  }

  provisioner "remote-exec" {
    inline = var.commands_to_execute
  }

}
