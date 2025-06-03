// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import { createIcons, icons } from 'lucide';
import "chartkick/chart.js"
import "./controllers"
import "./channels"
// Chat panel toggle
document.addEventListener("turbo:load", function() {
  const navToggle = document.getElementById("toggle_chat_panel_nav");
  const chatPanel = document.getElementById("chat_panel");
  
  if (navToggle && chatPanel) {
    navToggle.addEventListener("click", function() {
      chatPanel.classList.toggle("max-w-0");
      chatPanel.classList.toggle("max-w-2xl");
    });
  }
});

window.addEventListener('scroll', () => {
  if (window.location.pathname.includes("/app")) {
    const header = document.querySelector('header');
    if (window.scrollY > 10) {
      header.classList.add('bg-white', 'shadow-md');
      header.classList.remove('bg-[#0F172A]');
    } else {
      header.classList.remove('bg-white', 'shadow-md');
      header.classList.add('bg-[#0F172A]');
    }
  }
});

document.addEventListener("turbo:load", function() {
  if (document.getElementById("chat_panel")) {
    document.getElementById("close_chat_panel").addEventListener("click", function() {
      document.getElementById("chat_panel").classList.add("max-w-0");
      document.getElementById("chat_panel").classList.remove("max-w-2xl");
      document.getElementById("chat_panel").classList.remove("max-w-full");
    });
  }
  if (document.getElementById("toggle_chat_panel_full_screen")) {
    document.getElementById("toggle_chat_panel_full_screen").addEventListener("click", function() {
      document.getElementById("chat_panel").classList.toggle("max-w-full");
    });
  }
  if (document.getElementById("chat_messages")) {
    const chatMessages = document.getElementById("chat_messages");
    [...chatMessages.querySelectorAll("div > div > div > div > div")]?.at(0)?.scrollIntoViewIfNeeded()
  }
});

document.addEventListener("turbo:load", function() {
  createIcons({icons});
});

if (window.location.pathname === "/") {
  document.addEventListener("turbo:load", function() {

    // Mobile menu toggle
    function toggleMobileMenu() {
      const menu = document.getElementById('mobile-menu');
      menu.classList.toggle('hidden');
    }
    
    // FAQ toggle
    const faqButtons = document.querySelectorAll('.toggle-faq');
    faqButtons.forEach(button => {
      button.addEventListener('click', function() {
        const content = this.nextElementSibling;
        const icon = this.querySelector('i');
        
        content.classList.toggle('hidden');
        icon.style.transform = content.classList.contains('hidden') ? 'rotate(0deg)' : 'rotate(180deg)';
        
        // Update border color
        const container = this.parentElement;
        container.classList.toggle('border-red-500/50');
      });
    });

  });
}


// make #notice disappear after 3 seconds
document.addEventListener("turbo:load", function() {
  const notice = document.getElementById("notice");
  if (notice) {
    setTimeout(() => {
      notice.style.display = "none";
    }, 3000);
  }
});

document.addEventListener("turbo:load", function() {
  if (window.location.pathname.includes("/app")) {
    const keywordsTableHeader = document.getElementById("keywords_table_header");
    const keywordsTableContent = document.getElementById("keywords_table_content");
    const competitorsTableHeader = document.getElementById("competitors_table_header");
    const competitorsTableContent = document.getElementById("competitors_table_content");
    const backlinksTableHeader = document.getElementById("backlinks_table_header");
    const backlinksTableContent = document.getElementById("backlinks_table_content");

    keywordsTableHeader?.addEventListener("click", function() {
      keywordsTableContent.classList.toggle("hidden");
      competitorsTableContent.classList.add("hidden");
      backlinksTableContent.classList.add("hidden");
      keywordsTableHeader.querySelector(".lucide-chevron-up").classList.toggle("rotate-180");
      competitorsTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      backlinksTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      if (keywordsTableContent.classList.contains("hidden")) {
        window.scrollTo({
          top: 0,
          behavior: "smooth"
        })
      } else {
        window.scrollTo({
          top: 80,
          behavior: "smooth"
        })
      }
    });

    competitorsTableHeader?.addEventListener("click", function() {
      competitorsTableContent.classList.toggle("hidden");
      keywordsTableContent.classList.add("hidden");
      backlinksTableContent.classList.add("hidden");
      competitorsTableHeader.querySelector(".lucide-chevron-up").classList.toggle("rotate-180");
      keywordsTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      backlinksTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      if (competitorsTableContent.classList.contains("hidden")) {
        window.scrollTo({
          top: 0,
          behavior: "smooth"
        })
      } else {
        window.scrollTo({
          top: 180,
          behavior: "smooth"
        })
      }
    });

    backlinksTableHeader?.addEventListener("click", function() {
      backlinksTableContent.classList.toggle("hidden");
      competitorsTableContent.classList.add("hidden");
      keywordsTableContent.classList.add("hidden");
      backlinksTableHeader.querySelector(".lucide-chevron-up").classList.toggle("rotate-180");
      keywordsTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      competitorsTableHeader.querySelector(".lucide-chevron-up").classList.add("rotate-180");
      if (backlinksTableContent.classList.contains("hidden")) {
        window.scrollTo({
          top: 0,
          behavior: "smooth"
        })
      } else {
        window.scrollTo({
          top: 270,
          behavior: "smooth"
        })
      }
    });
  }
});