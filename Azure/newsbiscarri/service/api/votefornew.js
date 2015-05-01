/**
 * Created by joanbiscarri on 30/04/15.
 */
exports.post = function(request, response) {
    var myTable = request.service.tables.getTable('news');
    var newsId = request.query.newsId;

    function updateMyItem() {

        myTable.where({ id: newsId})
            .read({
                success: function(results) {
                    var res = results[0];
                    console.log('Voting ->'+res);
                    var votes = parseInt (res["votes"]);
                    votes++;
                    res["votes"] = votes;
                    console.log(res);
                    myTable.update(res);
                    response.send(200, {'message':'ok'});
                }
            });
    }

    updateMyItem();
}

