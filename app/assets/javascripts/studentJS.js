$(document).ready(function(){

	$("#student-update-button").click(function(event){
		if($("#info-pass-field").val() == ""){
			event.preventDefault();
			$("#info-pass-field").click();
		}
	});
	
	$("#lecturer-update-button").click(function(event){
		if($("#lec-info-pass-field").val() == ""){
			event.preventDefault();
			$("#lec-info-pass-field").click();
		}
	});
	
	$("#lec-info-pass-field").change(function(event){
		$("form[action='/change_lecturer_passport']").submit();
	});
	
	
	
	$("#info-pass-field").change(function(event){
		$("form[action='/change_passport']").submit();
	});

	$("#change_pass").click(function(event){
			event.preventDefault();
			$("#pass-modal").css("display", "block");
			$("#p-dn-match").css("display", "none");
			$("#password-error").css("display", "none");
			$("#p-match").css("display", "none");
			$("#info-opassword-field").val("");
			$("#info-npassword-field").val("");
			$("#info-cpassword-field").val("");
	});
	
	$("#close-pass-change").click(function(event){
			event.preventDefault();
			$("#pass-modal").css("display", "none");
	});
	
	$("#info-opassword-field").change(function(){
		if($(this).val().length < 6 ){
			$("#opassword-error").html("Password cannot be less thatn 6 characters");
			$("#opassword-error").css("display", "block");
			$(this).focus();
		}
		else{
			$("#opassword-error").css("display", "none");
		}
	});
	
	$("#info-opassword-field").blur(function(){
		if($(this).val().length < 6 ){
			$("#opassword-error").html("Password cannot be less thatn 6 characters");
			$("#opassword-error").css("display", "block");
			$(this).focus();
		}
		else{
			$("#opassword-error").css("display", "none");
		}
	});
	
	$("#info-cpassword-field").keyup(function(){
		if($("#info-cpassword-field").val() === $("#info-npassword-field").val()){
			$("#p-match").html("Passwords Match");
			$("#p-match").css("display", "block");
			$("#p-dn-match").css("display", "none");
		}
		else{
			$("#p-match").css("display", "none");
		}
	});	
	
	$("#info-cpassword-field").blur(function(event){
			if($("#info-cpassword-field").val() != $("#info-npassword-field").val()){
				$("#p-dn-match").html("Passwords do not Match");
				$("#p-dn-match").css("display", "block");
				$("#p-match").css("display", "none");
				$(this).focus();
			}
			else{
				$("#p-dn-match").css("display", "none");
				$("#p-match").html("Passwords Match");
				$("#p-match").css("display", "block");
			}
	});
	
	
	$("#info-npassword-field").change(function(event){
			var val = $(this).val();
			if(val.length < 6){
				$("#password-error").html("Password cannot be less thatn 6 characters");
				$("#password-error").css("display", "block");
				$(this).focus();
			}
			else{
				$("#password-error").css("display", "none");
			}
	});
	
	$("#info-npassword-field").blur(function(event){
			var val = $(this).val();
			if(val.length < 6){
				$("#password-error").html("Password cannot be less thatn 6 characters");
				$("#password-error").css("display", "block");
				$(this).focus();
			}
			else{
				$("#password-error").css("display", "none");
			}
	});
	
	
});
