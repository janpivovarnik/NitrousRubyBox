GoodData::Model::ProjectBuilder.create("DataXu Vodafone Project") do |p|
    p.add_date_dimension("score")

    p.add_dataset("score") do |d|
        d.add_anchor("week_id")
        d.add_date("score", :dataset => "score")
        d.add_fact("value")
    end

    p.add_dataset("pc") do |d|
      d.add_attribute("pcxval")
      d.add_attribute("pcyval")
      d.add_fact("pcval")
    end

    p.add_dataset("pcg") do |d|
      d.add_attribute("pcgxval")
      d.add_attribute("pcgyval")
      d.add_fact("pcgval")
    end

end