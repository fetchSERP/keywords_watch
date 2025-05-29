// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import { createIcons, icons } from 'lucide';
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
  const header = document.querySelector('header');
  if (window.scrollY > 10) {
    header.classList.add('bg-white', 'shadow-md');
    header.classList.remove('bg-[#0F172A]');
  } else {
    header.classList.remove('bg-white', 'shadow-md');
    header.classList.add('bg-[#0F172A]');
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
    [...chatMessages.querySelectorAll("div > div > div > div > div")][0].scrollIntoViewIfNeeded()
  }
});

if (window.location.pathname === "/") {
  document.addEventListener("turbo:load", function() {
    createIcons({icons});

    // Mobile menu toggle
    function toggleMobileMenu() {
      const menu = document.getElementById('mobile-menu');
      menu.classList.toggle('hidden');
    }
    
    // FAQ toggle
    function toggleFAQ(button) {
      const content = button.nextElementSibling;
      const icon = button.querySelector('i');
      
      content.classList.toggle('hidden');
      icon.style.transform = content.classList.contains('hidden') ? 'rotate(0deg)' : 'rotate(180deg)';
      
      // Update border color
      const container = button.parentElement;
      container.classList.toggle('border-red-500/50');
    }
  });
}