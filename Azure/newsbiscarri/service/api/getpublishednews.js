exports.get = function(request, response) {
    var mssql = request.service.mssql;
    var sql = "select autor,imageuri,votes,titulo,id from news where estado='PUBLISHED' order by __updatedAt desc";
    console.log(sql);
    mssql.query(sql, {
        success:function(results)
        {
            console.log(results);
            response.send(200,results);            
        },
        error:function(error)
        {
            console.log(error);
            response.send(500,error);                        
        }
    })
};