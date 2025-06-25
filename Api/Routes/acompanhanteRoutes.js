/**
 * @file Defines the routes for caregiver (acompanhante) authentication and management.
 * These routes map HTTP requests to the appropriate controller functions for caregivers.
 */

const express = require('express');
// Assuming the controller file is located at '../../Controller/acompanhanteController.js'
// relative to this routes file (Api/Routes/acompanhanteRoutes.js).
// Adjust the path if your folder structure is different.
const { cadastrar, login, consultar, editar, excluir, consultarUm} = require('../../Controller/acompanhanteController.js');
const { autenticarAcompanhante } = require('../Middleware/authAcompanhante.js');

// Create a new router object to define a modular set of routes.
const router = express.Router();

/**
 * @route   POST /api/caregivers/Cadastro
 * @desc    Register a new caregiver (acompanhante)
 * @access  Public
 * @body    { "nome_completo": "string", "email": "string", "senha": "string", "telefone": "string", "data_nascimento": "Date", "cpf": "string", "endereco_completo": "string" }
 */
router.post('/Cadastro', cadastrar);

/**
 * @route   POST /api/caregivers/Login
 * @desc    Login an existing caregiver (acompanhante)
 * @access  Public
 * @body    { "email": "string", "senha": "string" }
 */
router.post('/Login', login);

// Listar todos os acompanhantes (GET)
router.get('/', consultar);

// Editar acompanhante (PUT)
router.put('/:id', autenticarAcompanhante, editar);

// Excluir acompanhante (DELETE)
router.delete('/:id', excluir);

router.get('/:id', consultarUm);

// Export the router to be mounted by the main application.
module.exports = router;