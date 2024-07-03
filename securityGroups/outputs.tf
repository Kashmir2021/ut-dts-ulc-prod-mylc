output "Mylc_App" {
  value = "${aws_security_group.Mylc_App.id}"
}

output "Public_ELB" {
  value = "${aws_security_group.Public_ELB.id}"
}

output "Public_Mylc_ELB" {
  value = "${aws_security_group.Public_Mylc_ELB.id}"
}
