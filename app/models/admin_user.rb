class AdminUser < ApplicationRecord
  # Sem :registerable — administradores não se autocadastram (SECURITY.md).
  devise :database_authenticatable, :recoverable, :rememberable,
         :validatable, :trackable, :lockable
end
