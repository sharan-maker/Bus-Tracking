const supabase = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  static async create(email, password, firstName, lastName, role) {
    try {
      const hashedPassword = await bcrypt.hash(password, 10);

      const { data, error } = await supabase
        .from('users')
        .insert([{
          email,
          password_hash: hashedPassword,
          first_name: firstName,
          last_name: lastName,
          role
        }])
        .select('user_id, email, role, first_name, created_at')
        .single();

      if (error) throw new Error(error.message);
      return data;
    } catch (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }
  }

  static async findByEmail(email) {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .single();

      if (error && error.code !== 'PGRST116') throw new Error(error.message);
      return data;
    } catch (error) {
      throw new Error(`Error finding user: ${error.message}`);
    }
  }

  static async verifyPassword(password, hashedPassword) {
    return await bcrypt.compare(password, hashedPassword);
  }
}

module.exports = User;