
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "example" {
  ami           = "ami-id"
  instance_type = "t2.micro"
  #key_name      = "example_keypair"
  
  # Attach an IAM role to the instance that grants permission for SSM
  iam_instance_profile  = "ec2instanceProfile"
  
  
  # Install the SSM agent on the instance
  user_data = <<-EOF
              #!/bin/bash
              echo "Installing SSM agent..."
              sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
              sudo systemctl start amazon-ssm-agent
              EOF
}

resource "aws_ssm_document" "example" {
  name = "example-ssm-document"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2"
    description = "Example SSM document"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name = "example-command"
        inputs = {
          runCommand = ["ls -l /"]
        }
      }
    ]
  })
}

output "instance_id" {
  value = aws_instance.example.id
}

output "ssm_document_id" {
  value = aws_ssm_document.example.id
}
