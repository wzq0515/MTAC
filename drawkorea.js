$(document).ready(function(){
    
    $('#select').click(function(){
        var formData = new FormData();
        var filedata= document.getElementById('file').files[0];
        formData.append("file",filedata);
        alert("여기까지됨");
        
        
        $.ajax({
          url: './upload.php',
                dataType: 'script',
                
                contentType: false,
                processData: false,
                data: formData,                                         
                type: 'post',
                success: function(returndata){
                    alert("returndata"); 
                }
          });
    });})

  