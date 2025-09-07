const fieldSKU = document.getElementById('fieldSKU')
const fieldNombre = document.getElementById('fieldNombre')
const fieldPrecio = document.getElementById('fieldPrecio')
const textoPrecioPack =  document.getElementById('textoPrecioPack')
const selectModelo = document.getElementById('selectModelo')
const selectMedida = document.getElementById('selectMedida')
const selectColor = document.getElementById('selectColor')
const checkEsPack = document.getElementById('checkEsPack')
const fieldUnidades = document.getElementById('fieldUnidades')
const buscadorReferencia = document.getElementById('buscadorReferencia')
const selectReferencia = document.getElementById('selectReferencia')
const botonCargar = document.getElementById('botonCargar')
let modelosDisponibles
let medidasPorModelo
let coloresPorModelo
let productosUnitarios
let optionsOriginales
let timerFiltro

const conseguirMedidas = async (idModelo) => {
    try {
        const res = await fetch(`/listarMedidasPorModelo?idModelo=${encodeURIComponent(idModelo)}`)
        return await res.json()
    }
    catch (error) {
        alert(error.message)
        return {medidas : [{idMedida : -1, numero : 0}]}
    }
}

const llenarSelectMedidas = () => {
    selectMedida.innerHTML = ''
    if (medidasPorModelo.medidas.length > 0) {
        const optionPorDefecto = document.createElement('option')
        optionPorDefecto.textContent = '-- seleccionar medida --'
        optionPorDefecto.value = -1
        selectMedida.appendChild(optionPorDefecto)
        for (const medida of medidasPorModelo.medidas) {
            const optionMedida = document.createElement('option')
            optionMedida.textContent = medida.numero
            optionMedida.value = medida.idMedida
            selectMedida.appendChild(optionMedida)
        }
        selectMedida.disabled = false
    }
    else {
        optionPorDefecto.textContent = '-- sin medidas asignadas --'
        optionPorDefecto.value = -1
        selectMedida.appendChild(optionPorDefecto)
        selectMedida.disabled = true
    }
}

const conseguirColores = async (idModelo) => {
    try {
        const res = await fetch(`/listarColoresPorModelo?idModelo=${encodeURIComponent(idModelo)}`)
        return await res.json()
    }
    catch (error) {
        alert(error.message)
        return {colores : [{idColor : -1, nombre : 'Sin colores cargados para ese modelo'}]}
    }
}

const llenarSelectColores = () => {
    selectColor.innerHTML = ''
    if (coloresPorModelo.colores.length > 0) {
        const optionPorDefecto = document.createElement('option')
        optionPorDefecto.textContent = '-- seleccionar color --'
        optionPorDefecto.value = -1
        selectColor.appendChild(optionPorDefecto)
        for (const color of coloresPorModelo.colores) {
            const optionColor = document.createElement('option')
            optionColor.textContent = color.nombre
            optionColor.value = color.idColor
            selectColor.appendChild(optionColor)
        }
        selectColor.disabled = false
    }
    else {
        const optionPorDefecto = document.createElement('option')
        optionPorDefecto.textContent = '-- sin colores asignados --'
        optionPorDefecto.value = -1
        selectColor.appendChild(optionPorDefecto)
        selectColor.disabled = true
    }
}

const habilitarSelectsMedidaYColor = async () => {
    if (selectModelo.value === -1)
        return

    const idModelo = selectModelo.value

    medidasPorModelo = await conseguirMedidas(idModelo)
    llenarSelectMedidas()
    selectMedida.addEventListener('change', primeraSeleccionMedida)

    coloresPorModelo = await conseguirColores(idModelo)
    llenarSelectColores()
    selectColor.addEventListener('change', primeraSeleccionColor)
}

const primeraSeleccionModelo = () => {
    const options = selectModelo.getElementsByTagName('option')
    options[0].remove()
    selectModelo.removeEventListener('change', primeraSeleccionModelo)
    habilitarSelectsMedidaYColor()
    selectModelo.addEventListener('change', habilitarSelectsMedidaYColor)
}

const primeraSeleccionMedida = () => {
    const options = selectMedida.getElementsByTagName('option')
    options[0].remove()
    selectMedida.removeEventListener('change', primeraSeleccionMedida)
}

const primeraSeleccionColor = () => {
    const options = selectColor.getElementsByTagName('option')
    options[0].remove()
    selectColor.removeEventListener('change', primeraSeleccionColor)
}

const conseguirModelos = async () => {
    try {
        const res = await fetch('/listarModelosId')
        return await res.json()
    }
    catch (error) {
        alert(error.message)
        return {modelos : [{idModelo : -1, nombre : 'Sin modelos cargados'}]}
    }
}

const llenarSelectModelos = (modelos) => {
    const valorPorDefecto = document.createElement('option')
    valorPorDefecto.value = -1
    valorPorDefecto.textContent = '-- seleccionar modelo --'
    valorPorDefecto.selected = true
    selectModelo.appendChild(valorPorDefecto)
    for (const modelo of modelos.modelos) {
        const optionModelo = document.createElement('option')
        optionModelo.textContent = modelo.nombre
        optionModelo.value = modelo.idModelo
        selectModelo.appendChild(optionModelo)
    }
}

const conseguirReferencias = async () => {
    try {
        const res = await fetch('/listarProductosUnitariosId')
        return await res.json()
    }
    catch (error) {
        alert(error.message)
        return {productos : [{idProducto : -1, SKU : 'N/D', nombre : 'no hay productos unitarios'}]}
    }
}

const llenarSelectReferencia = (productos) => {
    const optionPorDefecto = document.createElement('option')
    optionPorDefecto.textContent = '-- seleccionar referencia --'
    optionPorDefecto.value = -1
    for (const producto of productos.productos) {
        const option = document.createElement('option')
        option.textContent = producto.nombre
        option.value = producto.idProducto
        selectReferencia.appendChild(option)
    }
    optionsOriginales = Array.from(selectReferencia.options)
}

const habilitarReferencia = async () => {
    selectReferencia.disabled = false
    buscadorReferencia.disabled = false
    fieldPrecio.disabled = true
    textoPrecioPack.style.visibility = 'visible'
    selectModelo.disabled = true
    fieldUnidades.disabled = false

    selectReferencia.innerHTML = ''
    productosUnitarios = await conseguirReferencias()
    llenarSelectReferencia(productosUnitarios)

    cambiarSelectModelo()
}

const deshabilitarReferencia = () => {
    selectReferencia.disabled = true
    buscadorReferencia.disabled = true
    fieldPrecio.disabled = false
    textoPrecioPack.style.visibility = 'hidden'
    selectModelo.disabled = false
    fieldUnidades.disabled = true

    selectReferencia.innerHTML = ''
    const optionPorDefecto = document.createElement('option')
    optionPorDefecto.textContent = '-- seleccionar "es pack" para habilitar --'
    optionPorDefecto.value = -1
    selectReferencia.appendChild(optionPorDefecto)

    selectModelo.innerHTML = ''
    for (const modelo of modelosDisponibles.modelos) {
        const option = document.createElement('option')
        option.textContent = modelo.nombre
        option.value = modelo.idModelo
        selectModelo.appendChild(option)
    }
}

const cambiarSelectModelo = async () => {
    selectModelo.innerHTML = ''
    
    if (selectReferencia.value == -1) {
        const optionNoValida = document.createElement('option')
        optionNoValida.textContent = '-- ningun elemento coincide con la busqueda --'
        optionNoValida.value = -1
        selectModelo.appendChild(optionNoValida)
        selectMedida.disabled = true
        selectColor.disabled = true
    }
    else {
        let idModeloReferencia
        for (const productoReferencia of productosUnitarios.productos) {
            if (productoReferencia.idProducto == selectReferencia.value) {
                idModeloReferencia = productoReferencia.idModelo
            }
        }

        for (const modelo of modelosDisponibles.modelos) {
            if (modelo.idModelo == idModeloReferencia) {
                const optionModeloReferencia = document.createElement('option')
                optionModeloReferencia.textContent = modelo.nombre
                optionModeloReferencia.value = modelo.idModelo
                selectModelo.appendChild(optionModeloReferencia)
            }
        }
        medidasPorModelo = await conseguirMedidas(idModeloReferencia)
        llenarSelectMedidas(medidasPorModelo)
        coloresPorModelo = await conseguirColores(idModeloReferencia)
        llenarSelectColores(coloresPorModelo)

        selectMedida.disabled = false
        selectColor.disabled = false
    }
}

const inicializarPagina = async () => {
    fieldSKU.addEventListener('keypress', (event) => {
        if (event.key === 'Enter')
            fieldNombre.focus()
    })

    fieldNombre.addEventListener('keypress', (event) => {
        if (event.key === 'Enter')
            fieldPrecio.focus()
    })

    fieldPrecio.addEventListener('keypress', (event) => {
        if (event.key === 'Enter')
            fieldPrecio.blur()
    })

    fieldPrecio.onblur = () => {
        fieldPrecio.value = Number(fieldPrecio.value).toFixed(2).toString()
    }

    selectModelo.addEventListener('change', primeraSeleccionModelo)

    checkEsPack.onclick = async () => {
        if (checkEsPack.checked)
            await habilitarReferencia()
        else
            deshabilitarReferencia()
    }

    buscadorReferencia.addEventListener('input', () => {
        const intervalo = 500

        clearTimeout(timerFiltro)
        timerFiltro = setTimeout(() => {
            const filtro = buscadorReferencia.value.toLowerCase()
            selectReferencia.innerHTML = ''

            const optionsFiltradas = optionsOriginales.filter(option => option.textContent.toLowerCase().includes(filtro))
            if (optionsFiltradas.length > 0) {
                optionsFiltradas.forEach(option => selectReferencia.appendChild(option))
                selectReferencia.disabled = false
            }
            else {
                const optionNoCoincide = document.createElement('option')
                optionNoCoincide.textContent = 'Ningun elemento coincide con la busqueda'
                optionNoCoincide.value = -1
                selectReferencia.appendChild(optionNoCoincide)
                selectReferencia.disabled = true
            }

            cambiarSelectModelo()
        }, intervalo);
    })

    selectReferencia.addEventListener('change', cambiarSelectModelo)

    modelosDisponibles = await conseguirModelos()
    llenarSelectModelos(modelosDisponibles)
}

inicializarPagina()