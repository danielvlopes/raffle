# RaffleController.rb
# Raffle
#
# Created by daniellopes on 16/01/10 based on Matt Aimonetti MacRuby Example

require 'yaml'

class RaffleController < NSWindowController
  # windows
  attr_accessor :add_sheet, :main_window
  # data controls
  attr_accessor :nameTableView, :prizes
  # fields
  attr_accessor :prize_name, :winner_name, :close_button, :email, :participants

  def awakeFromNib
    retrieve_names
    retrieve_prizes
    nameTableView.doubleAction = "edit:"
  end
  
  def windowWillClose(sender)
   exit
  end

  def yaml_file
    @yaml_file = File.expand_path("~/Documents/winners.yml")
  end
  
  def retrieve_names
    @names = File.exist?(yaml_file) ? YAML.load_file(yaml_file) : []
    @nameTableView.dataSource = self
  end
  
  def retrieve_prizes
    @prizes.removeAllItems
    ['PeepCode 1º', 'Peepcode 2º', 'Peepcode 3º', 
     'Curso Rails', 'Curso Ruby', 'Curso BDD', 
     'Curso Deploy', 'Cloud 2', 'Cloud 3', 'Cloud 4', 
     'Cloud 5', 'Cloud 6'].each do |title|
      @prizes.addItemWithTitle title
    end 
  end

  def numberOfRowsInTableView(view)
    @names.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    filter = @names[index]
    case column.identifier
      when 'prize_name'
        filter[:prize_name] ? filter[:prize_name] : ""
      when 'winner_name'
        filter[:winner_name] ? filter[:winner_name] : ""
      when 'email'
        filter[:email] ? filter[:email] : ""
    end
  end
  
  def add(sender)
    @sheet_mode = :add
    close_button.title = 'Adicionar'
    prize_name.stringValue = @prizes.selectedItem.title.to_s
    winner_name.stringValue = email.stringValue = ''
    show_panel
  end
  
  def edit(sender)
    if nameTableView.selectedRow != -1
      prize_name.stringValue = @names[nameTableView.selectedRow][:prize_name] || ''
      winner_name.stringValue = @names[nameTableView.selectedRow][:winner_name] || ''
      email.stringValue =  @names[nameTableView.selectedRow][:email] || ''
      @sheet_mode = :edit
      close_button.title = 'Gravar'
      show_panel
    else
      alert
    end
  end
  
  def close_add(sender)
    if @sheet_mode == :add
      add_name!
    else
      edit_name!
    end
    @add_sheet.orderOut(nil)
    NSApp.endSheet(@add_sheet)
  end
  
  def cancel(sender)
    @add_sheet.orderOut(nil)
    NSApp.endSheet(@add_sheet)
  end
  
  def remove(sender)
    if nameTableView.selectedRow != -1
      @names.delete_at(nameTableView.selectedRow)
      save_names
    else
      alert
    end
  end
  
  def add_name!
    new_filter = {}
    new_filter[:prize_name] = prize_name.stringValue
    new_filter[:winner_name]  = winner_name.stringValue
    new_filter[:email]       = email.stringValue
    unless new_filter.empty?
     @names << new_filter
     save_names
    end
  end
  
  def edit_name!
    updated_rule = {}
    updated_rule[:prize_name] = prize_name.stringValue
    updated_rule[:winner_name]  = winner_name.stringValue
    updated_rule[:email]       = email.stringValue
    @names[nameTableView.selectedRow] = updated_rule
    save_names
  end
  
  def save_names
    File.open(yaml_file, 'w'){|f| f << @names.to_yaml}
    retrieve_names
    nameTableView.reloadData
  end
  
  def do_raffle(sender)
    if @participants.intValue <= 0
      alert("Zero participantes", "Por favor defina o número de participantes") 
    else
      winner = rand(@participants.intValue - 1)
      prize  = @prizes.selectedItem.title.to_s
      alert("Prêmio #{prize}"," O vencedor foi o nº: #{winner}")
    end
  end
    
  def alert(title='Nada selecionado', message='Você deve selecionar uma linha!', icon="")
    NSAlert.alertWithMessageText(title, 
                                 defaultButton: 'OK',
                                 alternateButton: nil, 
                                 otherButton: 'Cancelar',
                                 informativeTextWithFormat: message).runModal
  end
  
  def show_panel
    NSApp.beginSheet(@add_sheet, 
      modalForWindow:@main_window, 
      modalDelegate:self, 
      didEndSelector:nil,
      contextInfo:nil)
  end
  
end
