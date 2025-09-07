const fieldNombre = document.getElementById('fieldNombre')
const selectRubro = document.getElementById('selectRubro')
const botonCargar = document.getElementById('botonCargar')
const contenedorTabla = document.getElementById('contenedorTabla')
let modelosDisponibles

const conseguirRubros = async () => {
    try {
        const res = await fetch('/listarRubrosId')
        return await res.json()
    }
    catch (error) {
        alert(error.message)
    }
}

const llenarSelectRubro = (rubros) => {
    for (const rubro of rubros.rubros) {
        const option = document.createElement('option')
        option.textContent = rubro.nombre
        option.value = rubro.idRubro
        selectRubro.appendChild(option)
    }
}

const conseguirModelos = async () => {
    try {
        const res = await fetch('/listarModelosIdRubro')
        return await res.json()
    }
    catch (error) {
        alert(error.message)
        return {modelos : []}
    }
}

const mostrarModelos = () => {
    const tabla = document.createElement('table')
    const header = document.createElement('thead')
    const body = document.createElement('tbody')
    body.id = 'bodyTablaModelos'

    const titulos = document.createElement('tr')
    const nombre = document.createElement('th')
    nombre.textContent = 'Nombre'
    const rubro = document.createElement('th')
    rubro.textContent = 'Rubro'
    const acciones = document.createElement('th')
    acciones.textContent = 'Acciones'

    titulos.appendChild(nombre)
    titulos.appendChild(rubro)
    titulos.appendChild(acciones)
    header.appendChild(titulos)

    for (const modelo of modelosDisponibles.modelos) {
        const registro = document.createElement('tr')
        registro.id = modelo.idModelo
        const datoNombre = document.createElement('td')
        datoNombre.textContent = modelo.nombre
        const datoRubro = document.createElement('td')
        datoRubro.textContent = modelo.rubro

        const botonEliminarModelo = document.createElement('button')
        botonEliminarModelo.textContent = 'Eliminar'
        botonEliminarModelo.onclick = async () => {
            try {
                const res = await fetch(`/modelo/${encodeURIComponent(modelo.idModelo)}`, {
                    method : 'DELETE'
                })
                
                const mensaje = await res.json()

                if (!mensaje.ok)
                    throw new Error(mensaje.mensaje)

                if (mensaje.ok) {
                    const registroEliminado = document.getElementById(modelo.idModelo)
                    registroEliminado.remove()
                }
                alert(mensaje.mensaje)
            }
            catch (error) {
                alert(error.message)
            }
        }
        const botones = document.createElement('td')
        botones.appendChild(botonEliminarModelo)
        
        registro.appendChild(datoNombre)
        registro.appendChild(datoRubro)
        registro.appendChild(botones)
        body.appendChild(registro)
    }

    tabla.appendChild(header)
    tabla.appendChild(body)
    contenedorTabla.appendChild(tabla)
}

const inicializarPagina = async () => {
    rubrosDisponibles = await conseguirRubros()
    llenarSelectRubro(rubrosDisponibles)

    botonCargar.onclick = async () => {
        if (fieldNombre.value != '') {
            const modelo = {
                nombre : fieldNombre.value.trim().toLowerCase(),
                idRubro : selectRubro.value
            }

            const respuesta = await fetch('/agregarModelo', {
                method : 'POST',
                headers : {'Content-Type' : 'application/json'},
                body : JSON.stringify(modelo)
            })

            const resultado = await respuesta.json()
            if (resultado.ok) {
                fieldNombre.value = ''
                const registro = document.createElement('tr')
                registro.id = resultado.idModelo
                const datoNombre = document.createElement('td')
                datoNombre.textContent = modelo.nombre
                const datoRubro = document.createElement('td')
                datoRubro.textContent = selectRubro.options[selectRubro.selectedIndex].textContent
                const eliminar = document.createElement('td')
                const botonEliminar = document.createElement('button')
                botonEliminar.textContent = 'Eliminar'
                botonEliminar.onclick = async () => {
                    try {
                        const res = await fetch(`/modelo/${encodeURIComponent(resultado.idModelo)}`, {
                            method : 'DELETE'
                        })
                        
                        const mensaje = await res.json()

                        if (!mensaje.ok)
                            throw new Error(mensaje.mensaje)
                        else {
                            const registroEliminado = document.getElementById(resultado.idModelo)
                            registroEliminado.remove()
                        }
                        alert(mensaje.mensaje)
                    }
                    catch (error) {
                        alert(error.message)
                    }
                }
                registro.appendChild(datoNombre)
                registro.appendChild(datoRubro)
                eliminar.appendChild(botonEliminar)
                registro.appendChild(eliminar)
                document.getElementById('bodyTablaModelos').appendChild(registro)
            }
        }
    }

    modelosDisponibles = await conseguirModelos()
    mostrarModelos()
}

inicializarPagina()