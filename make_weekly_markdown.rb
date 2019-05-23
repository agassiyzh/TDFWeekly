#!/usr/bin/env ruby

require "psych"
require "fileutils"

@total_file_name = "total"
@template = Psych.load_file("template.yaml")
@category_in_template = @template.map { |e| e["category"] }
@time = Time.now
@week_based_year = @time.strftime("%V")
@year = @time.year()

@category = {}

def clear_old_markdown(file_path)
  def a(file_path)
    if File.directory? file_path
      Dir.foreach(file_path) do |file|
        sub_file_path = file_path + "/" + file
        File.delete sub_file_path if file == @total_file_name + ".markdown" or (@category_in_template.map { |c| c + ".markdown" }).include? file
        a(sub_file_path) if (file != "." and file != ".." and File.directory? sub_file_path)
      end
    end
  end

  a(file_path)
end

def merge_files(target_file_path = "", sub_file_paths = [])
  target_file = File.open(target_file_path, "a")
  sub_file_paths.each do |sub_file_path|
    sub_file = File.open(sub_file_path, "r")
    sub_file.each do |line|
      target_file << line
    end
    sub_file.close()
  end

  target_file.close()
end

def traverse_dir(file_path)
  if File.directory? file_path
    Dir.foreach(file_path) do |file|
      if "." != file and ".." != file
        sub_file_path = file_path + "/" + file

        if File.directory? sub_file_path
          traverse_dir(sub_file_path)

          sub_total_file_path = sub_file_path + "/" + @total_file_name + ".markdown"

          merge_files(file_path + "/" + @total_file_name + ".markdown", [sub_total_file_path]) if File.exist? sub_total_file_path

          @category_in_template.each do |category|
            sub_category_file_path = sub_file_path + "/" + category + ".markdown"
            target_category_file_path = file_path + "/" + category + ".markdown"
            merge_files(target_category_file_path, [sub_category_file_path]) if File.exist? sub_category_file_path
          end
        end

        yaml_to_markdown(sub_file_path) if File.extname(sub_file_path) == ".yaml"
      end
    end
  end
end

def yaml_to_markdown(file_path)
  yaml = Psych.load_file(file_path)

  title = "## " + yaml["name"] + " - " + yaml["organization"].join(" - ") + "\n\n"

  content = yaml["weekly report content"]

  s = ""

  content.each do |item|
    is_category_in_template = @category_in_template.include?(item["category"])

    if is_category_in_template
      content_in_template = (@template.select { |t| item["category"] == t["category"] }).first["content"]

      next if item["content"] == content_in_template or item["content"].gsub(/[[:space:]]/, "").length == 0
    end

    s << "### " + item["title"] + "\n\n" + item["content"] + "\n\n"

    next unless @category_in_template.include?(item["category"])

    category_content_str = title + item["content"] + "\n"

    category_file_path = File.dirname(file_path) + "/" + item["category"] + ".markdown"

    @category[category_file_path] = {
      "path" => category_file_path,
      "title" => item["title"],
      "contents" => [],
    } unless @category.has_key?(category_file_path)

    @category[category_file_path]["contents"].insert(-1, category_content_str)

    category_title = "# " + item["title"] + "\n\n"

    File.open(category_file_path, "w") { |f| f << "# " + item["title"] + "\n\n" } unless File.exist? category_file_path
    File.open(category_file_path, "a") { |f| f << title + item["content"] + "\n" }
  end

  s = title + s

  markdown_file_path = "#{yaml["year"]}/#{yaml["week"]}/#{yaml["organization"].join("/")}/#{yaml["name"]}.markdown"

  File.open(markdown_file_path, "w") { |file| file << s }

  File.open(File.dirname(markdown_file_path) + "/#{@total_file_name}.markdown", "a+") { |file| file << s }
end

clear_old_markdown("#{@year}/#{@week_based_year}")

traverse_dir("#{@year}/#{@week_based_year}")
