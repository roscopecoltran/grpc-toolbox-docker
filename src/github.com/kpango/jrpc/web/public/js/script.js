$(function() {
  $("#proto-file").html("Response Values");

  $("#gen").click(function() {

    var JSONdata = {
      package_name: $("#pkg").val(),
      service_name: $("#service").val(),
      rpcs: [{
        name: $("#rpc").val(),
        stream_mode: parseInt($("#rpc_mode").val()),
        req_name: $("#reqname").val(),
        res_name: $("#resname").val(),
        req_body: $("#reqbody").val(),
        res_body: $("#resbody").val(),
      }]
    };

    $.ajax({
      type: 'post',
      url: '/proto',
      data: JSON.stringify(JSONdata),
      contentType: 'application/JSON',
      dataType: 'JSON',
      scriptCharset: 'utf-8',
      success: function(data) {
        // Success
        $("#proto-file").html(data.responseText);
      },
      error: function(data) {
        // Error
        $("#proto-file").html(data.responseText);
      }
    });
  });

  $("#add").click(function() {

  });
});
