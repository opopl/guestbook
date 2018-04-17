$(document).ready(function(){

			var msgs_page=$('#msgs_page').val() || 10;

			var table_id = "#table_list_msgs";
			var table = $(table_id).DataTable({
				"info"         : false,
				"searching"    : false,
				"pagingType"   : "full_numbers",
				"lengthChange" : false,
				"pageLength"   : msgs_page,
				language: {
					url: "json/datatables/Russian.json"
				}
			});

			var head_id = table_id + "_head";

			$( head_id ).change( function(){
					var filtered = table.$('tr',{'filter' : 'applied' });

					filtered.each(function(index){
							$( $(this) ).find("td input[type='checkbox']").click();
						}
					);
			});

			$('#msgs_page').keypress( function (e) {
					var len = $(this).val();
					if(e.which == 13) {
						table.page.len( len ).draw();
					}
			});	

});
