const { postgresConnection } = require('../Config/instaceConn.js'); // Adjust path if necessary

// 2. Get the Knex instance from the postgresConnection.
//    'db' is now your Knex instance, ready for use.
const db = postgresConnection.getConnection();

exports.criarEmergencia = async (dados) => {
  return await db('emergencia').insert(dados).returning('*');
};

exports.buscarEmergenciaPorDependente = async (dependente_id) => {
  return await db('emergencia').where({ dependente_id }).first();
};

exports.atualizarEmergencia = async (dependente_id, dados) => {
  return await db('emergencia').where({ dependente_id }).update(dados).returning('*');
};

exports.buscarEmergenciaPorDependente = async (dependente_id) => {
  return await db('emergencia').where({ dependente_id }).first();
};