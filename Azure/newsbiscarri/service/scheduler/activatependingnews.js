function activatependingnews() {

    var myTable = tables.getTable('news');

    function updateMyItem() {

        myTable.where({ estado: 'PENDING'})
            .read({
                success: function(results) {
                    for (var i=0; i<results.length; i++){
                        var res = results[i];
                        res["estado"] = "PUBLISHED";
                        myTable.update(res);
                    }
                }
            });
    }

    updateMyItem();
    
}