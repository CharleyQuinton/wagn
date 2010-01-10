class AdminController < ApplicationController
  layout 'application'
  
  def setup
    raise(Wagn::Oops, "Already setup") if User.first_login
    if request.post?  
      Card::User  # wtf - trigger loading of Card::User, otherwise it tries to use U
      User.as :wagbot do
        @user, @card = User.create_with_card( params[:extension].merge({:login=>'first'}), params[:card] )
      end
      
      if @user.errors.empty?
        @user.roles = [Role[:admin]]
        self.current_user = @user
        flash[:notice] = "You're good to go!" 
        redirect_to '/'
      else
        flash[:notice] = "Durn, setup went awry..."
      end
    else
      @card = Card.new( params[:card] || {} )
      User.first_login = @user = User.new( params[:user] || {} )
    end
  end
  
  def tasks
    System.ok!(:set_global_permissions)
    @tasks = System.role_tasks
    @roles = Role.find_configurables.sort{|a,b| a.card.name <=> b.card.name }
    @role_tasks = {}
    @roles.each { |r| @role_tasks[r.id] = r.task_list }
  end
  
  def save_tasks
    System.ok!(:set_global_permissions)    
    role_tasks = params[:role_task]
    Role.find( :all ).each  do |role|
      tasks = role_tasks[role.id.to_s] || {}
      role.tasks = tasks.keys.join(',')
      role.save
    end
  
    flash[:notice] = 'permissions saved'
    redirect_to :action=>'tasks'
  end
  
end
