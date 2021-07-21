let selected = "0"
let interact = null

$(function() {
    console.log = function(){}
    document.onkeydown = function(k) {
        if (k.which == 27) {
            
            $("#all").addClass('cerrarmenu').fadeOut(200, function() {
                cleanMenu();
                $(this).removeClass('cerrarmenu');
                $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}))
                interact = null
            });
           
        }
    }
    window.addEventListener("message", function(event) {
        // COMPRUEBA SI HAY ALGÚN MENÚ AUN CARGADO Y SI LO HAY, ESPERA A QUE SE OCULTE EL ANTERIOR
        let v = event.data
        if($(".te").length==0){
            drawMenu(event.data);
        } else {
            setTimeout( function(){
                drawMenu(event.data);
            }, 500);
        }
        
        if (v.selected) {
            $("#" + selected).removeClass("selected")
            selected = v.selected
            $("#" + v.selected).addClass("selected")
        }

        if (v.move == "no") {
            $("#all").addClass('cerrarmenu').fadeOut(200, function() {
                cleanMenu();
                $(this).removeClass('cerrarmenu');
                interact = null
                $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}))
            });
        }
        
        if (v.toExecute) {
            $("#all").addClass('cerrarmenu').fadeOut(200, function() {
                cleanMenu();
                $(this).removeClass('cerrarmenu');
            });
            $.post(`https://${GetParentResourceName()}/` + interact, JSON.stringify({
                text: $("#" + v.toExecute).attr('text'),
                execute: $("#" + v.toExecute).attr('execute'),
            }));
            $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}))
            interact = null
            selected = "0"
        }

    });
});

document.addEventListener("DOMContentLoaded", function(event) {
    const element = document.getElementById("all")
    element.style = "display:none"
});

function cleanMenu() {
    $(".te").remove();
    $("span").remove();
    $(".arrow").remove();
    $(".te table-code hvr-rectangle-out hvr-icon-forward").remove();
}


function drawMenu(v){
    if (v.title) {
        interact = v.cb
        $("#all").css("right", "15%")
        $("#all").css("top", "35%")

        $("#menu").append(`
            <span class="title">${v.title}</span>
        `);
        for (var i = 0; i < v.data.length; i++) {
            let icono = 'fa-chevron-circle-right';
            if (v.data[i]['icon'] != undefined) {
                icono = v.data[i]['icon'];
            }

            let delay = i/10;  //DELAY DE ANIMACIÓN AL MOSTRAR LISTA 
            $("#menu-container").append(`
            <div class="te table-code hvr-rectangle-out hvr-icon-forward" id = "${i}" style="animation-delay:${delay}s" text="${v.data[i]['text']}" execute="${v.data[i]['toDo']}"> 
            ${v.data[i]['text']}<i class="fas ${icono}"></i>
            </div>
            `);


            if (i == v.data.length - 1) {
                if (v.useCoords == true) {
                    $(".toAppend").append(`<div class="arrow"></div>`)
                }
                $("#all").fadeIn(500)
            }
        }

        $("#0").addClass("selected")

    }

    
}