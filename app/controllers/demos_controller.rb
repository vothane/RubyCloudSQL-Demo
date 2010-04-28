require 'ruby_cloud_sql'

class DemosController < ApplicationController
  # GET /demos
  # GET /demos.xml
  def index
    message_options = {"success" => "All data loaded.", "failure" => "Unable to retrieve data"}
    sql = "SELECT * FROM #{@table}"
    response = @ruby_cloud_sql.zoho_find_by_sql( @DB, @table, sql )

    get_response = convert_response( response.nil? ? false : true, message_options, response.nil? ? {} : response )
    
    respond_to do |format|
      format.html { render :json => get_response.to_json }
      format.xml  { render :json => get_response.to_json }
    end
  end

  # POST /demos
  # POST /demos.xml
  def create
    new_row_data = params[:data]
    message_options = {"success" => "Row successfully created.", "failure" => "Unable to create new row"}
	
    row_created = @ruby_cloud_sql.zoho_create( @DB, @table, new_row_data )
	
    if row_created
      sql = "SELECT * FROM #{@table} WHERE #{query_conditions( new_row_data )}"
      response = @ruby_cloud_sql.zoho_find_by_sql( @DB, @table, sql )
    end
	
    post_response = convert_response( response.nil? ? false : true, message_options, response.nil? ? {} : response )
    
    respond_to do |format|
      format.html { render :json => post_response.to_json }
      format.xml  { render :json => post_response.to_json }
    end
  end

  # PUT /demos/1
  # PUT /demos/1.xml
  def update
    request_data = params[:data]
    update_data = request_data.dup
    update_data.delete "id" if update_data.has_key? "id"
	
    message_options = {"success" => "Row with id # #{request_data["id"]} successfully updated.", "failure" => "Unable to update row with data."}

    row_updated = @ruby_cloud_sql.zoho_update( @DB, @table, "(\"id\" = '#{request_data["id"]}')", update_data )

    if row_updated
      sql = "SELECT * FROM #{@table} WHERE #{query_conditions( request_data )}"
      response = @ruby_cloud_sql.zoho_find_by_sql( @DB, @table, sql )
    end

    put_response = convert_response( response.nil? ? false : true, message_options, response.nil? ? {} : response )

    respond_to do |format|
      format.html { render :json => put_response.to_json }
      format.xml  { render :json => put_response.to_json }
    end
  end

  # DELETE /demos/1
  # DELETE /demos/1.xml
  def destroy
    delete_request_id = params[:id]	
    message_options = {"success" => "Row with id # #{delete_request_id} successfully destroyed. KaBOOM!!!.", "failure" => "Unable to delete row."}

    row_deleted = @ruby_cloud_sql.zoho_delete( @DB, @table, "(\"id\" = '#{delete_request_id}')" )

    delete_response = convert_response( row_deleted, message_options, {} )

    respond_to do |format|
      format.html { render :json => delete_response.to_json }
      format.xml  { render :json => delete_response.to_json }
    end
  end

  before_filter :login

  private
  
  def login
    @DB = "DB"
    @table = "names"
    configs = {:login_name => '*******', :password => '******', :database_name => 'DB', :api_key => '42d46c3fb9cad1fba2712b8bf91317bb'}
    @ruby_cloud_sql = RubyCloudSQL.new( configs )
	data_migrated = @ruby_cloud_sql.zoho_migrate( @DB, @table, "#{RAILS_ROOT}/public/migrations/migrate.csv" )
  end

  def convert_response( successful, message_options, hash_data = {} )
    new_response = {}
    
    fill_response = Proc.new do |sucesssful, data|
      new_response["success"] = sucesssful
      new_response["message"] = successful ? message_options["success"] : message_options["failure"]
      new_response["data"] = data
    end
	
    if successful && hash_data.empty?.eql?( false )
      columns = hash_data["rows"]["row"]
      data_as_array = []

      standardize_data = Proc.new do |col|
        row = col["column"]
        row_data = Hash.new
        row.each do |cell|
          row_data[cell["name"]] = cell["content"]
        end
        data_as_array << row_data
      end

      if columns.is_a? Array
        columns.each do |column|
          standardize_data.call( column )
        end
      else
        standardize_data.call( columns )
      end   
      fill_response.call( successful, data_as_array )
    elsif successful && hash_data.empty?.eql?( true )   
      fill_response.call( successful, [] )
    else   
      fill_response.call( successful, [] )
    end

    new_response
  end

  def query_conditions( data )
    pairs = []
    data.each do |key, value|
      pairs << "\"#{key}\"='#{value}'"
    end

    query_string = "#{pairs.join(" AND ")}"
  end
end
