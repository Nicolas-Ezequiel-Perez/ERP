import mariadb from 'mariadb'

const pool = mariadb.createPool({
  host: 'localhost', 
  user: 'root',
  password: 'jii99uk9o7',
  database: 'GDiseno',
  port: 3306,
  connectionLimit: 5,
  bigIntAsNumber: true
});

export const listarProductos = async () => {
    let conexion;
    try {
        conexion = await pool.getConnection()
        const productos = await conexion.query('CALL producto_listar()')
        return productos[0]
    }
    catch (error) {
        console.log(error.message)
    }
    finally {
        if (conexion)
            conexion.end()
    }
};

export const buscarPorNombre = async (busqueda) => {
    let conexion;
    try {
        conexion = await pool.getConnection()
        let busquedaSegura = busqueda.replace(/\\/g, '\\\\')
        busquedaSegura = busquedaSegura.replace(/%/g, '\\%').replace(/_/g, '\\_')
        const productos = await conexion.query('CALL producto_buscarNombre (?)', '%' + busquedaSegura + '%')
        return productos[0]
    }
    catch (error) {
        console.log(error.message)
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarModelosId = async () => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const modelos = await conexion.query('CALL modelo_listarId()')
        return modelos[0]
    }
    catch (error) {
        console.log(error.message)
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarMedidasPorModelo = async (idModelo) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const medidas = await conexion.query('CALL medida_listarPorModelo(?)', idModelo)
        return medidas[0]
    }
    catch (error) {
        console.log(error.message)
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarColoresPorModelo = async (idModelo) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const colores = await conexion.query('CALL puede_ser_color_listarColores(?)', idModelo)
        return colores[0]
    } 
    catch (error) {
        console.log(error.message)
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarProductosUnitariosId = async () => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const productos = await conexion.query('CALL producto_listarUnitarios()')
        return productos[0]
    }
    catch (error) {
        console.log(error)
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const agregarProductoUnitario = async (producto) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        conexion.query = await conexion.query(
            'CALL producto_agregarUnidad(?, ?, ?, ?, ?, ?)',
            producto.sku,
            producto.nombre,
            producto.precio,
            producto.idModelo,
            producto.idMedida,
            producto.idColor
        )
    }
    catch (error) {
        console.log(error.message)
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarRubros = async () => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const rubros = await conexion.query('CALL rubro_listar()')
        return rubros[0]
    }
    catch (error) {
        console.log(error.message)
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const agregarModelo = async (modelo) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const datos = await conexion.query(
            'CALL modelo_agregar(?, ?)',
            [
                modelo.nombre,
                modelo.idRubro
            ]
        )
        return {ok : true, mensaje : 'Modelo insertado correctamente', idModelo : datos[0][0].idNuevo}
    }
    catch (error) {
        return {ok : false, mensaje : 'Ya existe un modelo con ese nombre'}
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarModelosIdRubro = async () => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const modelos = await conexion.query('CALL modelo_listarIdRubro()')
        return modelos[0]
    }
    catch (error) {
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const eliminarModelo = async (idModelo) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        await conexion.query('CALL modelo_borrar(?)', idModelo)
        return {ok : true, mensaje : 'modelo eliminado correctamente'}
    }
    catch (error) {
        return {ok : false, mensaje : 'hay al menos un producto con este modelo'}
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const listarRubrosId = async () => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const rubros = await conexion.query('CALL rubro_listarId()')
        return rubros[0]
    }
    catch (error) {
        console.log(error.message)
        return []
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const eliminarRubro = async (idRubro) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        await conexion.query('CALL rubro_borrar(?)', idRubro)
        return {ok : true, mensaje : 'rubro eliminado correctamente'}
    }
    catch (error) {
        return {ok : false, mensaje : 'hay al menos un modelo con este rubro'}
    }
    finally {
        if (conexion)
            conexion.end()
    }
}

export const agregarRubro = async (rubro) => {
    let conexion
    try {
        conexion = await pool.getConnection()
        const datos = await conexion.query('CALL rubro_agregar(?, ?)',[
            rubro.nombre,
            rubro.idPadre
        ])
        return {ok : true, mensaje : 'Rubro insertado correctamente', idRubro : datos[0][0].idNuevo}
    }
    catch (error) {
        return {ok : false, mensaje : 'No se pudo insertar el rubro'}
    }
    finally {
        if (conexion)
            conexion.end()
    }
}