// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery-ui
//= require jquery_ujs
//= require bootstrap.min
//= require jquery.selectric.min
//= require turbolinks
//= require classie
//= require modalEffects
//= require jquery.mask
//= require override_confirm
//= require_tree .

$(document).ready(function () {

  $(function(){
    $('select').selectric();
  });

  $(document).on("focus", "[class~='date-picker']", function(e){
    $(this).datepicker({ 
      changeMonth: true,
      changeYear: true,
      yearRange: (new Date).getFullYear()-110 + ":" + (new Date).getFullYear()
    });
  });

  $('input.floatlabel').floatlabel({
    slideInput: false
  });
  
  $(".address-li").on('click',function(){
    $(".address-span").html($(this).data("address-text"));
    $(".address-row").hide();
    divtoshow = $(this).data("value") + "-div";
    $("."+divtoshow).show();
  });

  $('.autofill_yes').click(function(){
      });

  $('.autofill_no').click(function(){
    $('.autofill-cloud').addClass('hidden');
    side_bar_link_style();
  });


  /* QLE Marriage Date Validator */
  $('#date_married').focusin(function() {
    $('#date_married').removeClass('input-error');
  });

  $('#qle_marriage_submit').click(function() {
    if(check_marriage_date()) {
      get_qle_marriage_date();
    } else {
      $('#date_married').addClass('input-error');
    }
  });

  function check_marriage_date() {
    var date_value = $('#date_married').val();
    if(date_value == "" || isNaN(Date.parse(date_value)) || Date.parse(date_value) > Date.parse(new Date())) { return false; }
    return true;
  }

  function get_qle_marriage_date() {
    $.ajax({
      type: "GET",
      data:{date_val: $("#date_married").val()},
      url: "/people/check_qle_marriage_date.js"
    });
  }
  
  // People/new Page
  $('.back').click(function() {
    //Sidebar Switch - Personal Active
    $('#personal_sidebar').removeClass('hidden');
    $('#search_sidebar').addClass('hidden');

    //
    $('.search_results').addClass('hidden');
    $('#address_info').removeClass('hidden');
    $('#phone_info').removeClass('hidden');
    $('#email_info').removeClass('hidden');
  });

  $('.focus_effect').click(function(e){
    var check = check_personal_info_exists();
    active_div_id = $(this).attr('id');
    if( check.length==0 && (!$('.autofill-failed').hasClass('hidden') || $('.autofill-cloud').hasClass('hidden'))) {
      $('.focus_effect').removeClass('personal-info-top-row');
      $('.focus_effect').removeClass('personal-info-row');
      $('.focus_effect').addClass('personal-info-row');
      $(this).addClass('personal-info-top-row');
      $('.sidebar a').removeClass('style_s_link');
      $('.sidebar a.'+active_div_id).addClass('style_s_link');
      $(this).removeClass('personal-info-row');
    }
    if(active_div_id!='personal_info') {
      if(check.length!=0) {
        $('#personal_info .col-md-10').addClass('require-field');
      }
    }
  });

  $('#personal_info.focus_effect').focusout(function(){
    var tag_id = $(this).attr('id');
    var has_class = $(this).hasClass('personal-info-top-row');
    var check = check_personal_info_exists();
    if(check.length!=0 && !has_class) {
      $('#personal_info .col-md-10').addClass('require-field');
    }
    else {
      $('#personal_info .col-md-10').removeClass('require-field');
    }
  });

  $('span.close').click(function(){
    common_body_style();
    side_bar_link_style();
  });

  function side_bar_link_style()
  {
    $('.sidebar a').removeClass('style_s_link');
    $('.sidebar a.address_info').addClass('style_s_link');
  }

  function common_body_style()
  {

    $('#personal_info').addClass('personal-info-row');
    $('.focus_effect').removeClass('personal-info-top-row');
    $('#address_info').addClass('personal-info-top-row');
    $('#address_info').removeClass('personal-info-row');
  }

  function check_personal_info_exists()
  {
    var check = $('#personal_info input[required]').filter(function() { return this.value == ""; });
    return check;
  }

  function check_dependent_info_exists()
  {
    var check = $('#new_family_member input[required]').filter(function() { return this.value == ""; });
    return check;
  }

  $(".adderess-select-box").focusin(function() {
    $(".bg-color").css({
      "background-color": "rgba(220, 234, 241, 1)",
      "height": "46px",
    });
  });

  $(".adderess-select-box").focusout(function() {
    $(".bg-color").css({
      "background-color": "rgba(255, 255, 255, 1)",
      "height": "46px",
    });
  });

  // Employer Registration
  $('.employer_step2').click(function() {
    
    // Display correct sidebar
    $('.credential_info').addClass('hidden');
    $('.name_info').addClass('hidden');
    $('.tax_info').addClass('hidden');
    $('.emp_contact_info').removeClass('hidden');
    $('.coverage_info').removeClass('hidden');
    $('.plan_selection_info').removeClass('hidden');

    // Display correct form fields
    $('#credential_info').addClass('hidden');
    $('#name_info').addClass('hidden');
    $('#tax_info').addClass('hidden');

    $('#emp_contact_info').removeClass('hidden');
    $('#coverage_info').removeClass('hidden');
    $('#plan_selection_info').removeClass('hidden');
  });

  $('.employer_step3').click(function() {
    
    // Display correct sidebar
    $('.emp_contact_info').addClass('hidden');
    $('.coverage_info').addClass('hidden');
    $('.plan_selection_info').addClass('hidden');

    $('.emp_contributions_info').removeClass('hidden');
    $('.eligibility_rules_info').removeClass('hidden');
    $('.broker-info').removeClass('hidden');

    // Display correct form fields
    $('#emp_contact_info').addClass('hidden');
    $('#coverage_info').addClass('hidden');
    $('#plan_selection_info').addClass('hidden');
    
    $('#emp_contributions_info').removeClass('hidden');
    $('#eligibility_rules_info').removeClass('hidden');
    $('#broker_info').removeClass('hidden');
  });
  
  $(document).on('click', '.close-fail', function() {
    $(".fail-search").addClass('hidden');
    $(".overlay-in").css("display", "none");
  });
  
  // ----- Focus Effect & Progress -----
  $("body").click(function(e) {
    fade_all();
    update_progress();
    if (e.target.id == "personal_info" || $(e.target).parents("#personal_info").size()) { 
      $('#personal_info div.first').addClass('employee-info');
      $("a.personal_info").css("color","#98cbff");
      $("#personal_info div.first").css("opacity","1");
    } 
    else if (e.target.id == "address_info" || $(e.target).parents("#address_info").size()) {
      $('#address_info div.first').addClass('employee-info');
      $("a.address_info").css("color","#98cbff");
      $("#address_info div.first").css("opacity","1");
      $("#top-pad").innerHTML="30%";
    }
    else if (e.target.id == "phone_info" || $(e.target).parents("#phone_info").size()) {
      $('#phone_info div.first').addClass('employee-info');
      $("a.phone_info").css("color","#98cbff");
      $("#phone_info div.first").css("opacity","1");
    }
    else if (e.target.id == "email_info" || $(e.target).parents("#email_info").size()) {
      $('#email_info div.first').addClass('employee-info');
      $("a.email_info").css("color","#98cbff");
      $("#email_info div.first").css("opacity","1");
    }
    else if (e.target.id == "household_info" || $(e.target).parents("#household_info").size()) {
      $('#household_info div.first').addClass('employee-info');
      $("a.household_info").css("color","#98cbff");
      $("#household_info div.first").css("opacity","1");
    }
    else {}
  });
  
  function fade_all() {
    
    if(!$("#address_info").hasClass('hidden')) {
      $("#personal_info div.first").css("opacity","0.5");
    }
    $("#address_info div.first").css("opacity","0.5");
    $("#phone_info div.first").css("opacity","0.5");
    $("#email_info div.first").css("opacity","0.5");
    $("#household_info div.first").css("opacity","0.5");
  }
  
  update_progress(); //Run on page load for dependent_details page.
  function update_progress() {

    var start_progress = $('#initial_progress').length ? parseInt($('#initial_progress').val()) : 0;

    if(start_progress == 0) {
      var personal_entry = check_personal_entry_progress();
      var address_entry  = check_address_entry_progress();
      var phone_entry    = check_phone_entry_progress();
      var email_entry    = check_email_entry_progress();
      
    }

    if(personal_entry) {
      start_progress = 20;
      $("a.one, a.two").css("color","#00b420");
    }

    if(address_entry) {
      start_progress += 8;
      $("a.three").css("color","#00b420");
    }

    if(phone_entry) {
      start_progress += 10;
      $("a.four").css("color","#00b420");
    }

    if(email_entry) {
      start_progress += 12;
      $("a.five").css("color","#00b420");
    }

    if($('#add_info_clone0').length) {
      start_progress += 15;
      $("a.six").css("color","#00b420");
    } else {$("a.six").css("color","#999");}

    $('#top-pad').html(start_progress + '% Complete');
    $('.progress-top').css('height', start_progress + '%');

    if(start_progress >= 50) {
      $('#continue-employer').removeClass('disabled');
    } else {
      $('#continue-employer').addClass('disabled');
    }
  }

  function check_personal_entry_progress() {
    gender_checked = $("#person_gender_male").prop("checked") || $("#person_gender_female").prop("checked");
    if(gender_checked==undefined) {
      return true;
    }
    if(check_personal_info_exists().length==0 && gender_checked) {
      return true;
    } else {
      $("a.one").css('color', '#999'); $("a.two").css('color', '#999');
      return false;
    }
  }

  function check_address_entry_progress() {
    var empty_address = $('#address_info input.required').filter(function() { return $(this).val() === ""; }).length;
    if(empty_address === 0) { return true; }
    else {
      $("a.three").css('color', '#999');
      return false;
    }
  }

  function check_phone_entry_progress() {
    var empty_phone = $('#phone_info input.required').filter(function() { return ($(this).val() === "" || $(this).val() === "(___) ___-____"); }).length;
    if(empty_phone === 0) { return true; }
    else {
      $("a.four").css('color', '#999');
      return false;
    }
  }

  function check_email_entry_progress() {
    var empty_email = $('#email_info input.required').filter(function() { return $(this).val() === ""; }).length;
    if(empty_email === 0) { return true; }
    else {
      $("a.five").css('color', '#999');
      return false;
    }
  }

  $("#dependent_ul .floatlabel").focusin(function() {
    $('.house').css("opacity","0.5");
    $(this).closest('.house').addClass('employee-info');
    $("a.dependent_ul").css("color","#98cbff");
    $(this).closest('.house').css("opacity","1");
  });
  $("#dependent_ul .floatlabel").blur(function() {
    $(this).closest('.house').css("opacity","0.5");
  });
  // ----- Finish Focus Effect & Progress -----
  
  //Employee Dependents Page
  $('#dependents_info #top-pad15, #dependents_info #top-pad30, #dependents_info #top-pad80').hide();
  $("#dependents_info a.one, #dependents_info a.two, #dependents_info a.three, #dependents_info a.four, #dependents_info a.five").css("color","#00b420");
  
  $('.add_member').click(function() {
    $('.fail-search').addClass('hidden');
    $("#dependent_buttons").removeClass('hidden');
    $("#dependent_buttons div:first").addClass('hidden');
    $('#dependent_buttons div:last').removeClass('hidden');
    $('.add-member-buttons').removeClass('hidden');
  });

  /*
  $(document).on('click', '.close-1', function() {
    $('#cancel_member').click();
  });*/
  
  $(document).on('click', '#cancel_member', function() {
    $("#dependent_buttons").removeClass('hidden');
    $(".dependent_list:last").addClass('hidden');
  });
  
  $('#save_member').click(function() {
    $('.new_family_member:last').submit();
  });
  
  // Email validation after 1 seconds of stopping typing
  $('#email_info input').keyup(function() {
    call_email_check(this);
  });
  
  $('#email_info input').focusout(function() {
    call_email_check(this);
  });

  function call_email_check(email) {
    var timeout;
    var email = $(email).val();

    if(timeout) {
        clearTimeout(timeout);
        timeout = null;
    }

    timeout = setTimeout(function() {
      check_email(email);
    }, 1000);
  }
  
  function check_email(email) {
    var re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    if(email != "" && !re.test(email)) {
      $('#email_error').text('Enter a valid email address. ( e.g. name@domain.com )');
      $('#email_info .email .first').addClass('field_error');
    } else {
      $('#email_error').text('');
      $('#email_info .email .first').removeClass('field_error');
    }
  }
  
  // Add new address
  $('.btn-new-address').click(function(e){
    e.preventDefault();
    $(".new-address-flow").css("display", "block");
  });
  
  $('.new-address-flow .cancel').click(function(){
    $(".new-address-flow").removeAttr("style");
  });

  $('.new-address-flow .confirm').click(function(){
    $(".new-address-flow").removeAttr("style");
    var new_address = $("#add-address").val();
    $("ul.dropdown-menu li:first-child").clone().appendTo(".dropdown ul.dropdown-menu");
    $("ul.dropdown-menu li:last-child a:nth-child(2)").text(new_address);
    $("ul.dropdown-menu li:last-child").data('value', new_address.substr(0, new_address.indexOf(' ')).toLowerCase()); //Get First word and lowercase
    $("ul.dropdown-menu li:last-child").data('address-text', new_address.replace(/ /g,'')) // Remove Whitespace

    if (($("#add-address").val()) !== "") {
      $("#dropdownMenu1 label").text($("#add-address").val());
    }else{}

    $('#address_info > .first').attr('id', ($("#add-address").val()));
    $('#address_info input').val("");
  });

  $('.dropdown-menu a.address-close').click(function() {
    if($("ul.dropdown-menu li").length > 1) {
      $(this).parent("ul.dropdown-menu li").remove();
    } else {
      alert("You cannot remove all addresses.");
    }
  });
  
  // Change Dropdown Address Text
  $('.address-li').on('click', function(){
    $("#dropdownMenu1 label").text($(this).text());
    $('#address_info > .first').attr('id', ($(this).text()));
  });
  
  // Select Plan Page
  $('#select-plan-btn1').click(function() {
    $(".select-plan p.detail").hide();
    $(this).hide();
    $(".select-plan-details").show();
  });

  $(document).on('click', '.select-plan .all-filter', function(){
    $(".all-filters-row").show();
  });

  $(document).on('click', '.selected-plans-row .close', function(){
    $(".select-plan .tab-content").removeClass("selected");
    $(".selected-plans-row").hide();
  });

  // Input Masks
  $(".phone_number").mask("(999) 999-9999");
  $(".zip").mask("99999");
  $("#person_ssn").mask("999999999");
  $(".person_ssn").mask("999999999");
  $(".address-state").mask("AA");
  $(".mask-ssn").mask("999999999");
  
  $("#person_ssn").focusout(function( event ) {
    if(!$.isNumeric($(this).val())) {
      $("[for='person_ssn']").css('display', 'none');
      $("[for='person_ssn']").css('opacity', 0);
    } else {
      $("[for='person_ssn']").css('display', 'block');
      $("[for='person_ssn']").css('opacity', 1);
    }
  });

  $('#dependent_buttons #save_member').click(function() {
    if(check_dependent_info_exists().length==0) {
      $('#add_info .employee-info').last().removeClass('require-field');
    } else {
      $('#add_info .employee-info').last().addClass('require-field');
    }
  });
  
  $('#employer .landing_personal_tab .first').focusin(function(){
    $(this).css('opacity', 1);
  });

  $('#search-employer,#save_member').click(function(){
    $('input[type="radio"]').tooltip('disable');
    $('.required-tooltip .required').each(function(i, obj){
      if($(obj).val() == '')
        $(obj).tooltip({placement: 'right', title: 'Required field'}).tooltip('show');
    })
    $('.required-tooltip .required').bind('mouseenter focusin', function(){
      $(this).tooltip('show').tooltip('hide');
    });
  });

  $(".floatlabel, .selectric-wrapper").focusin(function() { $(this).closest('.employee-info').css("opacity","1") });
  $(".floatlabel, .selectric-wrapper").blur(function() { $(this).closest('.employee-info').css("opacity","0.5") });
 
});

$(document).ready(function () {
  $("#contact > #address_info > div, #contact > #phone_info > div, #contact > #email_info > .email > div").click(function(){
    $("#contact > #address_info > div, #contact > #phone_info > div, #contact > #email_info > .email > div").addClass('focus_none');
    $("#contact > #address_info > div, #contact > #phone_info > div, #contact > #email_info > .email > div").removeClass('add_focus');
    $(this).removeClass('focus_none');
    $(this).addClass('add_focus');
  });

  $('.member_address_links').click(function(){
    var member_id = $(this).data('id');
    $.ajax({
      url: '/people/'+member_id+'/get_member',
      type: 'GET',
      success: function(response){
        $('#member_address_area').html(response);
      }
    });
    $('#dLabel').html($(this).text()+"<i class='glyphicon glyphicon-menu-down'></i>");
  });
});
