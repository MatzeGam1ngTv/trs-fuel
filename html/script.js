$(function() {

    $('.fuel-selector').hide();

    let config;
    let currentFuel = 0;
    let vehicleClass;
    let maxFuel = 0;

    window.addEventListener('message', event => {

        const item = event.data;

        if (item.action == 'show') {

            config = item.config;
            vehicleClass = item.vehicleClass;
            currentFuel = 0;

            $('.fuel-selector').show();
            $('.fuel-selector-price-text').text(`${currentFuel * config.PricePerLiter}${config.Currency}`);
            $('.fuel-selector-display-text').text(`${currentFuel}L`)

            if (config.Classes[vehicleClass]) {
                maxFuel = config.Classes[vehicleClass];
            } else {
                $.post('http://ug-fuel/close', JSON.stringify({
                    notification: '~y~Não podes encher o tanque deste veiculo.'
                }))
            }

        } else if (item.action == 'hide') {
            $('.fuel-selector').hide();
        }
    })

    $('.fuel-selector-button').click(function() {
        
        if ($(this).attr('class').includes('plus')) {
            if (currentFuel <= maxFuel - 1) {
                currentFuel += 1;
            } else {
                currentFuel = 0;
            }
        } else if ($(this).attr('class').includes('minus')) {
            if (currentFuel >= 1) {
                currentFuel -= 1;
            } else {
                currentFuel = maxFuel;
            }
        }

        $('.fuel-selector-display-text').text(`${currentFuel}L`)
        $('.fuel-selector-price-text').text(`${currentFuel * config.PricePerLiter}${config.Currency}`);
    })

    $('.fuel-selector-pay').click(function() {
        $.post('http://ug-fuel/pay', JSON.stringify({
            liters: currentFuel,
            price: currentFuel * config.PricePerLiter
        }))
    })

    document.onkeyup = function(event) {
        if (event.which == 8 || event.which == 27) {
            $.post('http://ug-fuel/close', JSON.stringify({}))
        }
    }
})
