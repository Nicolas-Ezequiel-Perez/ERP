import express from 'express'
import path from 'path'
import { fileURLToPath } from 'url';
import {
    buscarPorNombre,
    listarProductos,
    listarModelosId,
    listarMedidasPorModelo,
    listarColoresPorModelo,
    listarProductosUnitariosId,
    listarRubros,
    agregarModelo,
    listarModelosIdRubro,
    eliminarModelo,
    listarRubrosId,
    eliminarRubro,
    agregarRubro
} from './baseDeDatos.js';

export const router = express.Router();

// esto es porque como no estoy usando commonjs no tengo acceso a __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

router.use(express.static(path.join(__dirname, '../public')));

router.get(/^\/principal(\.html)?$/, (req, res) => {
    res.sendFile(path.join(__dirname, '../public', 'principal', 'index.html'));
})

router.get(/^\/verProductos(\.html)?$/, (req, res) => {
    res.sendFile(path.join(__dirname, '../public', 'verProductos', 'index.html'));
})

router.get(/^\/administrarProductos(\.html)?$/, (req, res) => {
    res.sendFile(path.join(__dirname, '../public', 'administrarModelos', 'index.html'));
})

router.get('/listarTodo', async (req, res) => {
    const respuestaQuery = await listarProductos()
    res.json({productos : respuestaQuery})
})

router.get('/buscar', async (req, res) => {
    const busqueda = req.query.busqueda
    const respuestaQuery = await buscarPorNombre(busqueda)
    res.json({productos : respuestaQuery})
})

router.get('/listarModelosId', async (req, res) => {
    const respuestaQuery = await listarModelosId()
    res.json({modelos : respuestaQuery})
})

router.get('/listarMedidasPorModelo', async (req, res) => {
    const idModelo = req.query.idModelo
    const respuestaQuery = await listarMedidasPorModelo(idModelo)
    res.json({medidas : respuestaQuery})
})

router.get('/listarColoresPorModelo', async (req, res) => {
    const idModelo = req.query.idModelo
    const respuestaQuery = await listarColoresPorModelo(idModelo)
    res.json({colores : respuestaQuery})
})

router.get('/listarProductosUnitariosId', async (req, res) => {
    const respuestaQuery = await listarProductosUnitariosId()
    res.json({productos : respuestaQuery})
})

router.get('/listarRubros', async (req, res) => {
    const respuestaQuery = await listarRubros()
    res.json({rubros : respuestaQuery})
})

router.post('/agregarModelo', async (req, res) => {
    try {
        const modelo = req.body
        const respuestaQuery = await agregarModelo(modelo)
        res.json(respuestaQuery)
    }
    catch (error) {
        res.status(500).json({ok : false, mensaje : error.message})
    }
})

router.get('/listarModelosIdRubro', async (req, res) => {
    const respuestaQuery = await listarModelosIdRubro()
    res.json({modelos : respuestaQuery})
})

router.delete('/modelo/:idModelo', async (req, res) => {
    try {
        const idModelo = req.params.idModelo
        const respuestaQuery = await eliminarModelo(idModelo)
        res.json(respuestaQuery)
    }
    catch (error) {
        res.status(500).json({ok : false, mensaje : error.message})
    }
})

router.get('/listarRubrosId', async (req, res) => {
    const respuestaQuery = await listarRubrosId()
    res.json({rubros : respuestaQuery})
})

router.delete('/rubro/:idRubro', async (req, res) => {
    try {
        const idRubro = req.params.idRubro
        const respuestaQuery = await eliminarRubro(idRubro)
        res.json(respuestaQuery)
    }
    catch (error) {
        res.status(500).json({ok : false, mensaje : error.message})
    }
})

router.post('/agregarRubro', async (req, res) => {
    try {
        const rubro = req.body
        const respuestaQuery = await agregarRubro(rubro)
        res.json(respuestaQuery)
    }
    catch (error) {
        res.status(500).json({ok : false, mensaje : error.message})
    }
})