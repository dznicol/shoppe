$(document).ready(function() {
  var product_name_input = $('#new_product #product_name');

  product_name_input.focusout(function() {
    if (product_name_input.length) {
      var product_name = product_name_input.val();
      var product_sku_input = $('#product_permalink');
      var product_sku = product_sku_input.val();
      if (! product_sku) {
        var new_sku = product_name.toLowerCase().replace(/\s+/g, '-');
        product_sku_input.val(new_sku);
      }
    }
  });
});
