nrf51Demo
=========
Update: Although this is an easier project to get started with, the nrf51AdvLogger has much better peripheral drivers, functionality and documentation. Look at that if you want something more challenging.

To get started quick download as zip using the 'Download ZIP' button on right. In eclipse go to File -> Import. Select 'Archive file' in 'General' category. Go through the wizard to import the project.

The path to GCC should be updated in the Makefile. Make and clean should work from Eclipse.

Also update the location of the JLink driver in Makefile. With this the generated bin file can be uploaded to the MCU, content can be erased, MCU can be reset etc.

One can also use the upload script after editing the path to JLink.

For more information and to contact me visit <a href="http://rumblingsofearthlord.com/blog/category/techie/">my blog here.</a>
