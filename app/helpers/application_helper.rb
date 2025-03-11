module ApplicationHelper
    def departments
      Department.all
    end
  
    def intakes
      [
        "January",
        "February", 
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]
    end
  
    def institutions
      Institution.all
    end
  
    def statuses
      ["Active", "Inactive"]
    end
  
    def delivery_methods
      ["Full Time", "Part Time", "Online"]
    end
  
    def tags
      Tag.all
    end
  end
  