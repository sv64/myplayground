
# lorax_templates/set_installer.tmpl 
#   append usr/share/anaconda/interactive-defaults.ks "ostreecontainer --url=/run/install/repo/@IMAGE_NAME@-@IMAGE_TAG@ --transport=oci --no-signature-verification"

# lorax_templates/configure_upgrades.tmpl
#  usr/share/anaconda/interactive-defaults.ks
#    "%post --erroronfail"
#    "sed -i 's/container-image-reference=.*/container-image-reference=ostree-image-signed:docker:\/\/@IMAGE_REPO_ESCAPED@\/@IMAGE_NAME@:@IMAGE_TAG@/' /ostree/deploy/default/deploy/*.origin"
#    "%end"
# 
#   usr/share/anaconda/post-scripts/configure_upgrades.ks 
#    "%post --erroronfail"
#    "sed -i 's/container-image-reference=.*/container-image-reference=ostree-image-signed:docker:\/\/@IMAGE_REPO_ESCAPED@\/@IMAGE_NAME@:@IMAGE_TAG@/' /ostree/deploy/default/deploy/*.origin"
#   "%end"

  sed 's/@IMAGE_NAME@/$(IMAGE_NAME)/'                        $(_BASE_DIR)/lorax_templates/$*.tmpl.in > $(_BASE_DIR)/lorax_templates/$*.tmpl

  sed 's/@IMAGE_TAG@/$(IMAGE_TAG)/'                          $(_BASE_DIR)/lorax_templates/$*.tmpl > $(_BASE_DIR)/lorax_templates/$*.tmpl.tmp
  mv $(_BASE_DIR)/lorax_templates/$*.tmpl{.tmp,}
  
  sed 's/@IMAGE_REPO_ESCAPED@/$(_IMAGE_REPO_DOUBLE_ESCAPED)/' $(_BASE_DIR)/lorax_templates/$*.tmpl > $(_BASE_DIR)/lorax_templates/$*.tmpl.tmp
  mv $(_BASE_DIR)/lorax_templates/$*.tmpl{.tmp,}

# boot.iso

  rm -Rf $(_BASE_DIR)/results || true
  rm /etc/rpm/macros.image-language-conf || true

  # Set the enrollment password
  sed 's/@ENROLLMENT_PASSWORD@/$(ENROLLMENT_PASSWORD)/' $(_BASE_DIR)/scripts/enroll-secureboot-key.sh.in > $(_BASE_DIR)/scripts/enroll-secureboot-key.sh

  # Download the secure boot key
  if [ -n "$(SECURE_BOOT_KEY_URL)" ]; then\
    curl --fail -L -o $(_BASE_DIR)/sb_pubkey.der $(SECURE_BOOT_KEY_URL);\
  fi

  # Set the default menu entry to the first one
  sed -i 's/set default="1"/set default="0"/' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-bios.cfg

  sed -i 's/set default="1"/set default="0"/' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-efi.cfg

  # Add Extra Boot Parameters to all menu entries
  sed -i 's/linux @KERNELPATH@ @ROOT@ quiet/linux @KERNELPATH@ @ROOT@ quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-bios.cfg

  sed -i 's/linuxefi @KERNELPATH@ @ROOT@ quiet/linuxefi @KERNELPATH@ @ROOT@ quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-efi.cfg

  sed -i 's/linux @KERNELPATH@ @ROOT@ rd.live.check quiet/linux @KERNELPATH@ @ROOT@ rd.live.check quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-bios.cfg

  sed -i 's/linuxefi @KERNELPATH@ @ROOT@ rd.live.check quiet/linuxefi @KERNELPATH@ @ROOT@ rd.live.check quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-efi.cfg

  sed -i 's/linux @KERNELPATH@ @ROOT@ nomodeset quiet/linux @KERNELPATH@ @ROOT@ nomodeset quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-bios.cfg

  sed -i 's/linuxefi @KERNELPATH@ @ROOT@ nomodeset quiet/linuxefi @KERNELPATH@ @ROOT@ nomodeset quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-efi.cfg

  sed -i 's/linux @KERNELPATH@ @ROOT@ inst.rescue quiet/linux @KERNELPATH@ @ROOT@ inst.rescue quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-bios.cfg

  sed -i 's/linuxefi @KERNELPATH@ @ROOT@ inst.rescue quiet/linuxefi @KERNELPATH@ @ROOT@ inst.rescue quiet $(EXTRA_BOOT_PARAMS)/g' /usr/share/lorax/templates.d/99-generic/config_files/x86/grub2-efi.cfg

  # Build boot.iso
  lorax -p $(IMAGE_NAME) -v $(VERSION) -r $(VERSION) -t $(VARIANT) \
          --isfinal --buildarch=$(ARCH) --volid=$(_VOLID) \
          $(_LORAX_ARGS) \
          --repo /etc/yum.repos.d/fedora.repo \
          --repo /etc/yum.repos.d/fedora-updates.repo \
          --add-template $(_BASE_DIR)/lorax_templates/set_installer.tmpl \
      --add-template $(_BASE_DIR)/lorax_templates/configure_upgrades.tmpl \
      --add-template $(_BASE_DIR)/lorax_templates/secure_boot_key.tmpl \
          $(_BASE_DIR)/results/
  mv $(_BASE_DIR)/results/images/boot.iso $(_BASE_DIR)/
