 # Email Marketing & Templating

 _(The code portion of this section is a work in progress.)_

 ---

 My email code currently powers all of carvana.com's templates via Iterable snippets, where campaign managers dynamically build out content by stacking snippet "modules" and customizing them for the design provided by the design team.

 As of 2023, Carvana's volume exceeds 600,000,000 deliveries annually for over 50 triggered and batched campaigns.

 To date, I have been responsible for the code used in 2 billion production emails to customers.

 ---

 Initially, Carvana used a host of custom HTML and MJML (a higher-level templating language that has been gaining popularity).

 MJML is easy to use for basic templates, but is very heavy (file size) and does not plug and play very well with custom modules.

 In 2020, I scrapped the entire MJML library and implemented my own HTML and CSS class/table system to streamline the process as the company migrated from Marketo to Iterable (by the way, Marketo is awful), reducing file sizes by over 90% and increasing engagement. Many email campaign managers are not aware that throughput is a basic reality of computer processing. If you are sending more kilobytes, then the time to complete campaign delivery is inherently longer.

 ---

 I have used, in order of experience:
 + Iterable
 + Marketo
 + Salesforce Marketing Cloud (previously ExactTarget)
 + Custom SMTP (Python)
 + Zapier (Email/SMS Workflow)
 + Mailchimp

---

For any company getting started on picking an ESP, my recommendation is Iterable. It is the best ESP I have used to date.
