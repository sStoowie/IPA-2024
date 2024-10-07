resource "aws_lb" "elb-webLB" {
  name                       = "${var.default_name}-elb-webLB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.AllowSSHandWeb.id]
  subnets                    = [aws_subnet.Public1.id, aws_subnet.Public2.id]
  enable_deletion_protection = false
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-elb-webLB"
  })
}

resource "aws_lb_target_group" "EC2TargetGroup" {
  name        = "EC2TargetGroup"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.testVPC.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
  tags = merge(local.default_tags, {
    Name = "${var.default_name}-EC2TargetGroup"
  })
}

resource "aws_lb_target_group_attachment" "lb-attachment1" {
  target_group_arn = aws_lb_target_group.EC2TargetGroup.arn
  target_id        = aws_instance.Server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "lb-attachment2" {
  target_group_arn = aws_lb_target_group.EC2TargetGroup.arn
  target_id        = aws_instance.Server2.id
  port             = 80
}

resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.elb-webLB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.EC2TargetGroup.arn
    type             = "forward"
  }
}
