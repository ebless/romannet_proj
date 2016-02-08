require 'rubygems'
require 'nokogiri'
require 'active_support/core_ext/hash/conversions'
require 'todoist_client'

TodoistClient.api_token = '966cd60f2e8d48f9850ff37f36c12cde715e9eb6'

class Assignment
	
	attr_accessor :assigned_for
	attr_accessor :type
	attr_accessor :details
	attr_accessor :due_date

	def initialize(assigned_for, type, details, due_date)
		@assigned_for = assigned_for
		@type = type
		@details = details
		@due_date = due_date
	end
	def print_assignment
		if @details != '.'
			puts 'The assignment for ' + @assigned_for + ' is of category ' + @type + ' and is due on ' + @due_date + ', and is titled ' + @details + '.'
		else
			puts 'The assignment for ' + @assigned_for + ' is of category ' + @type + ' and is due on ' + @due_date + ', and is titled ' + @details
		end
	end
	def convert_project_id
		if @assigned_for == "Middle East (sem 2) - 326S.1"
			@assigned_for = '162513934'
		elsif @assigned_for == "Hon Accel Precalc and Diff Calc - 8420Y.1"
			@assigned_for = '133260729'
		elsif @assigned_for == 'Hon French 4 - 442Y.1'
			@assigned_for = '133260730'
		elsif @assigned_for == 'Comp Sci Principles 2: Applications (sem 2) - 6012S.1'
			@assigned_for = '162881191'
		elsif @assigned_for == 'English 10 - 220Y.1'
			@assigned_for = '133260726'
		end
	end
end

page = Nokogiri::HTML(open('/Users/ebless/Desktop/assignment_center.html'))

assignments = page.css('#assignment-center-assignment-items')

rows = []

assignments.css('tr').each do |i|
	rows << i
end

tasks = []

rows.each do |i|
	row_hash = Hash.from_xml(i.to_s)
	row_hash2 = row_hash['tr']

	info = row_hash2['td']
	puts info
	details_hash = info[2]
	if details_hash.class == String
		details = details_hash.strip
	else
		details = details_hash['a']
	end

	#puts 'The assignment for ' + info[0] + ' is of category ' + info[1] + ' and is due on ' + info[4] + ', and is titled ' + details + '.'
	tasks << Assignment.new(info[0], info[1], details, info[4])
end

tasks.each do |i|
	i.print_assignment
	i.convert_project_id
	item = TodoistClient::Item.create(content: i.details, project_id: i.assigned_for, date_string: i.due_date)
	puts [item.id, item.content]
	item.save
end




