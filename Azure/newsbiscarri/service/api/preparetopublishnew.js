exports.post = function(request, response) {
    var myTable = request.service.tables.getTable('news');
    var newsId = request.query.newsId;

    function updateMyItem() {

        myTable.where({ id: newsId})
        .read({
            success: function(results) {                
                var res = results[0];
                                console.log(res);
                res["estado"] = "PENDING";
                console.log(res);
                myTable.update(res
                    //,{ success:response.send(200, {'message':'ok'}),
                    //error:response.send(500, {'message':'ko'}) }
                );
                response.send(200, {'message':'ok'});
            }
        });              
    }

    updateMyItem();
}
