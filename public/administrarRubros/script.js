const fieldRubro = document.getElementById('fieldRubro')
const botonAgregarRubro = document.getElementById('botonAgregarRubro')
const contenedorTabla = document.getElementById('contenedorTabla')
let rubrosDisponibles

const conseguirRubros = async () => {
    try {
        const res = await fetch('/listarRubrosId')
        return await res.json()
    }
    catch (error) {
        console.log(error.message)
        return {rubros : []}
    }
}

const mostrarRubros = (rubros) => {
    const tabla = document.createElement('table')
    const head = document.createElement('thead')
    const body = document.createElement('tbody')
    body.id = 'bodyTablaRubros'

    const titulos = document.createElement('tr')
    const tituloNombre = document.createElement('th')
    tituloNombre.textContent = 'Rubro'
    const acciones = document.createElement('th')
    acciones.textContent = 'Acciones'
    titulos.appendChild(tituloNombre)
    titulos.appendChild(acciones)
    head.appendChild(titulos)

    for (const rubro of rubros) {
        const registro = document.createElement('tr')
        registro.id = rubro.idRubro
        const datoNombre = document.createElement('td')
        datoNombre.textContent = rubro.nombre

        const eliminar = document.createElement('td')
        const botonEliminarRubro = document.createElement('button')
        botonEliminarRubro.textContent = 'Eliminar'
        botonEliminarRubro.onclick = async () => {
            try {
                const res = await fetch(`/rubro/${encodeURIComponent(rubro.idRubro)}`, {
                    method : 'DELETE'
                })

                const respuesta = await res.json()

                if (!respuesta.ok)
                    throw new Error(respuesta.mensaje)
                else {
                    const registroEliminado = document.getElementById(rubro.idRubro)
                    registroEliminado.remove()
                }

                alert(respuesta.mensaje)
            }
            catch (error) {
                alert(error.message)
            }
        }
        eliminar.appendChild(botonEliminarRubro)

        registro.appendChild(datoNombre)
        registro.appendChild(eliminar)
        body.appendChild(registro)
    }

    tabla.appendChild(head)
    tabla.appendChild(body)
    contenedorTabla.appendChild(tabla)
}

const inicializarPagina = async () => {
    rubrosDisponibles = await conseguirRubros()
    mostrarRubros(rubrosDisponibles.rubros)
    botonAgregarRubro.onclick = async () => {
        const rubro = {nombre : fieldRubro.value.trim().toLowerCase()}

        const res = await fetch('/agregarRubro', {
            method : 'POST',
            headers : {'Content-Type' : 'application/json'},
            body : JSON.stringify(rubro)
        })

        const resultado = await res.json()
        if (resultado.ok) {
            fieldRubro.value = ''
            const registro = document.createElement('tr')
            registro.id = resultado.idRubro
            const datoNombre = document.createElement('td')
            const eliminar = document.createElement('td')
            const botonEliminar = document.createElement('button')
            botonEliminar.textContent = 'Eliminar'

            datoNombre.textContent = rubro.nombre

            botonEliminar.onclick = async () => {
                try {
                    const res = await fetch(`/rubro/${encodeURIComponent(resultado.idRubro)}`, {
                        method : 'DELETE'
                    })

                    const respuesta = await res.json()

                    if (!respuesta.ok)
                        throw new Error(respuesta.mensaje)
                    else {
                        const registroEliminado = document.getElementById(resultado.idRubro)
                        registroEliminado.remove()
                    }

                    alert(respuesta.mensaje)
                }
                catch (error) {
                    alert(error.message)
                }
            }

            registro.appendChild(datoNombre)
            eliminar.appendChild(botonEliminar)
            registro.appendChild(eliminar)
            document.getElementById('bodyTablaRubros').appendChild(registro)
        }
        else {

        }
    }
}

inicializarPagina()