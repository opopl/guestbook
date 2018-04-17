

$(document).ready(
		function() { 

			var form_id   = '#form_add_message';
			var submit_id = form_id + " div.submit input[type='submit']";

			$(submit_id).click(function(){
					var valid = $(form_id).valid();
					if(valid)
					{
						document.forms[form_id].submit();
					}
			});

			$(form_id).validate({ 
				lang: 'ru',
				rules: {
					user: {
						required: true,
						minlength: 2
					},
					email: {
						required: true
					},
					msg: {
						required: true
					},
					captcha: {
						required: true
					}
				},
				messages: {
					user: {
						required: "Поле 'Имя' обязательно к заполнению!",
						minlength: "Введите не менее 2-х символов в поле 'Имя'"
					},
					email: {
						required: "Поле 'Email' обязательно к заполнению!",
						email: "Необходим формат адреса email"	
					},
					msg : {
						required: "Введите свое сообщение!"
					},
					captcha : {
						required: "Введите цифры с картинки!"
					}
				}
			});

		}
);
