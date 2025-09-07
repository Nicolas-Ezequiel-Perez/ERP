const fieldBusqueda = document.getElementById('fieldBusqueda')
const botonBuscar = document.getElementById('botonBuscar')
let datos
const ascendenteColumnas = {}
const textoOrdenar = 'ordenar'
const textoAscendente = '^'
const textoDescendente = 'v'
const botonesOrdenar = {}

fieldBusqueda.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
        event.preventDefault()
        botonBuscar.click()
    }
})

const ordenarProductos = (columna, ascendente) => {
    datos.productos.sort((a, b) => {
        if (ascendente) {
            if (a[columna] < b[columna])
                return 1
            else if (a[columna] > b[columna])
                return -1
            else if (a.nombre < b.nombre)
                return 1
            else
                return -1
        }
        else {
            if (a[columna] < b[columna])
                return -1
            else if (a[columna] > b[columna])
                return 1
            else if (a.nombre < b.nombre)
                return -1
            else
                return 1
        }
            
    })
}

const mostrarProductos = (datos) => {
    const tablaVieja = document.getElementById('contenido')
    if (tablaVieja)
        tablaVieja.remove()

    const contenedor = document.getElementById('contenedor')
     if (!datos.productos.length){
        const mensaje = document.createElement('h2')
        mensaje.id = 'contenido'
        mensaje.textContent = 'No hubo coincidencias'
        contenedor.appendChild(mensaje)
        return
    }

    const tabla = document.createElement('table')
    tabla.id = 'contenido'
    const header = document.createElement('thead')
    const cuerpo = document.createElement('tbody')

    const encabezado = document.createElement('tr')
    Object.keys(datos.productos[0]).forEach(key => {
        const titulo = document.createElement('th')
		titulo.textContent = key
        botonesOrdenar[key] = document.createElement('button')
        botonesOrdenar[key].textContent = textoOrdenar
        botonesOrdenar[key].onclick = () => {
            ordenarProductos(key, ascendenteColumnas[key].ascendente)
            mostrarProductos(datos)
            ascendenteColumnas[key].ascendente = !ascendenteColumnas[key].ascendente
            if (ascendenteColumnas[key].ascendente)
                botonesOrdenar[key].textContent = textoAscendente
            else
                botonesOrdenar[key].textContent = textoDescendente
        }
        titulo.appendChild(botonesOrdenar[key])
        encabezado.appendChild(titulo)
    })
    header.appendChild(encabezado)
    tabla.appendChild(header)

    datos.productos.forEach(producto => {
        const registro = document.createElement('tr')
        Object.values(producto).forEach(valor => {
            const dato = document.createElement('td')
            dato.textContent = valor
            registro.appendChild(dato)
        })
        cuerpo.appendChild(registro)
    })
    tabla.appendChild(cuerpo)

    contenedor.appendChild(tabla)
}

const buscarTexto = async (busqueda) => {
    try {
        if (busqueda === '') {
            inicializarPagina()
            return
        }
        const res = await fetch(`/buscar?busqueda=${encodeURIComponent(busqueda)}`);
        // el encodeURIComponent es para que lo formatee y no rompa el get
        datos = await res.json()

        mostrarProductos(datos)
    }
    catch (error) {
        alert(error.message);
    }
}

botonBuscar.onclick = () => {
    buscarTexto(document.getElementById('fieldBusqueda').value)
}

const conseguirProductos = async () => {
    try {
        const res = await fetch('/listarTodo');
        return res.json()
    }
    catch (error) {
        alert(error.message)
        //esto es para que no se rompa si no consigue nada, pero no se si esta bien
        return {productos : []}
    }
};

const inicializarPagina = async () => {
    datos = await conseguirProductos();
    for (const key in datos.productos[0])
        ascendenteColumnas[key] = {ascendente : true}
    mostrarProductos(datos)
}

inicializarPagina()